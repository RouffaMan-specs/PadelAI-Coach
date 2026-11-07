import Foundation
import SwiftData

@MainActor
final class MatchViewModel: ObservableObject {
    enum State: String {
        case idle = "Ready"
        case matchRunning = "Match running"
        case rallyRecording = "Recording rally"
        case breakTime = "Break"
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var rallyCount = 0
    @Published var automaticBreakDetection = false
    @Published var statusMessage = "Mount the iPhone behind the court."

    private var currentMatch: MatchRecord?
    private var modelContext: ModelContext?
    private let camera: CameraManager

    init(camera: CameraManager) {
        self.camera = camera
    }

    func attach(context: ModelContext) {
        modelContext = context
    }

    func startMatch() {
        guard state == .idle else { return }
        let record = MatchRecord()
        currentMatch = record
        modelContext?.insert(record)
        rallyCount = 0
        state = .matchRunning
        statusMessage = "Match started. Start the first rally when play begins."
    }

    func startRally() {
        guard state == .matchRunning || state == .breakTime else { return }
        guard camera.isConfigured else {
            statusMessage = "Camera is not ready yet."
            return
        }
        state = .rallyRecording
        statusMessage = "Recording active rally."
        camera.startClip { [weak self] url in
            guard let self else { return }
            if let url {
                self.currentMatch?.clipPaths.append(url.path)
                self.rallyCount += 1
                self.currentMatch?.rallyCount = self.rallyCount
            } else {
                self.statusMessage = "The rally clip could not be saved."
            }
        }
    }

    func endRally() {
        guard state == .rallyRecording else { return }
        state = .breakTime
        statusMessage = "Break detected manually. Camera preview remains active."
        camera.stopClip()
    }

    func finishMatch() {
        guard state != .idle else { return }
        if state == .rallyRecording { camera.stopClip() }
        currentMatch?.endedAt = .now
        currentMatch = nil
        state = .idle
        statusMessage = "Match saved to local history."
    }

    func automaticDetectionSignal(activityScore: Double) {
        guard automaticBreakDetection, state == .rallyRecording else { return }
        if ConservativeRallyDetector().shouldEndRally(recentActivityScore: activityScore) {
            endRally()
        }
    }
}
