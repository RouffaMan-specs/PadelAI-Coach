import SwiftUI

struct MatchScreen: View {
    @ObservedObject var camera: CameraManager
    @ObservedObject var match: MatchViewModel

    var body: some View {
        VStack(spacing: 14) {
            ZStack(alignment: .topLeading) {
                CameraPreview(session: camera.session)
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                Text(camera.isRecording ? "● REC" : "LIVE PREVIEW")
                    .font(.caption.bold())
                    .padding(9)
                    .background(.black.opacity(0.65))
                    .clipShape(Capsule())
                    .padding(12)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text(match.state.rawValue).font(.headline)
                    Text("Saved rallies: \(match.rallyCount)")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: match.state == .rallyRecording ? "record.circle.fill" : "pause.circle")
                    .font(.system(size: 30))
                    .foregroundStyle(match.state == .rallyRecording ? .red : .green)
            }

            Text(match.statusMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("Automatic break detection (experimental)", isOn: $match.automaticBreakDetection)
                .font(.subheadline)
                .disabled(match.state == .idle)

            if match.state == .idle {
                Button("Start match") { match.startMatch() }
                    .buttonStyle(PrimaryButtonStyle())
            } else {
                HStack(spacing: 12) {
                    Button(match.state == .rallyRecording ? "End rally" : "Start rally") {
                        if match.state == .rallyRecording { match.endRally() }
                        else { match.startRally() }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    Button("Finish") { match.finishMatch() }
                        .buttonStyle(SecondaryButtonStyle())
                }
            }

            if let error = camera.cameraError {
                Text(error).font(.caption).foregroundStyle(.red)
            }

            Text("Keep this screen open while recording. For best results, mount the iPhone securely in landscape, behind the baseline, with the full court visible.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .task {
            await camera.configure()
            camera.startSession()
        }
        .onDisappear { camera.stopSession() }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundStyle(.black)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.12))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
