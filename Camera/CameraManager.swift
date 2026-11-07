import AVFoundation
import Combine
import UIKit

@MainActor
final class CameraManager: NSObject, ObservableObject {
    @Published private(set) var isConfigured = false
    @Published private(set) var isRecording = false
    @Published var cameraError: String?

    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private var currentOutputURL: URL?
    private var completion: ((URL?) -> Void)?

    func configure() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        let granted: Bool
        if status == .authorized {
            granted = true
        } else if status == .notDetermined {
            granted = await AVCaptureDevice.requestAccess(for: .video)
        } else {
            granted = false
        }

        guard granted else {
            cameraError = "Camera permission is required. Enable it in Settings."
            return
        }

        do {
            try configureSession()
            isConfigured = true
        } catch {
            cameraError = error.localizedDescription
        }
    }

    private func configureSession() throws {
        session.beginConfiguration()
        session.sessionPreset = .hd1920x1080

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video, position: .back) else {
            session.commitConfiguration()
            throw CameraError.noCamera
        }

        let input = try AVCaptureDeviceInput(device: camera)
        guard session.canAddInput(input) else {
            session.commitConfiguration()
            throw CameraError.cannotAddInput
        }
        session.addInput(input)

        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        } else {
            session.commitConfiguration()
            throw CameraError.cannotAddOutput
        }

        if let connection = movieOutput.connection(with: .video),
           connection.isVideoRotationAngleSupported(0) {
            connection.videoRotationAngle = 0
        }
        session.commitConfiguration()
    }

    func startSession() {
        guard isConfigured, !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stopSession() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func startClip(completion: @escaping (URL?) -> Void) {
        guard isConfigured, session.isRunning, !movieOutput.isRecording else {
            completion(nil)
            return
        }
        let url = Self.makeClipURL()
        currentOutputURL = url
        self.completion = completion
        movieOutput.startRecording(to: url, recordingDelegate: self)
        isRecording = true
    }

    func stopClip() {
        guard movieOutput.isRecording else { return }
        movieOutput.stopRecording()
    }

    private static func makeClipURL() -> URL {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("RallyClips", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("rally-\(UUID().uuidString).mov")
    }

    enum CameraError: LocalizedError {
        case noCamera, cannotAddInput, cannotAddOutput
        var errorDescription: String? {
            switch self {
            case .noCamera: return "No rear camera was found."
            case .cannotAddInput: return "Could not add the camera input."
            case .cannotAddOutput: return "Could not add the video recording output."
            }
        }
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    nonisolated func fileOutput(_ output: AVCaptureFileOutput,
                                didFinishRecordingTo outputFileURL: URL,
                                from connections: [AVCaptureConnection],
                                error: Error?) {
        Task { @MainActor in
            isRecording = false
            let result = (error == nil) ? outputFileURL : nil
            completion?(result)
            completion = nil
            currentOutputURL = nil
            if let error { cameraError = error.localizedDescription }
        }
    }
}
