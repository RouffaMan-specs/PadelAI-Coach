import SwiftUI
import SwiftData

@main
struct PadelAICoachApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: MatchRecord.self)
    }
}
