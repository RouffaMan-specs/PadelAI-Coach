import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var camera = CameraManager()
    @StateObject private var match: MatchViewModel
    @State private var selectedTab = 0

    init() {
        let manager = CameraManager()
        _camera = StateObject(wrappedValue: manager)
        _match = StateObject(wrappedValue: MatchViewModel(camera: manager))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MatchScreen(camera: camera, match: match)
                    .navigationTitle("Padel AI Coach")
            }
            .tabItem { Label("Record", systemImage: "camera") }
            .tag(0)

            HistoryScreen()
                .tabItem { Label("History", systemImage: "clock") }
                .tag(1)
        }
        .onAppear { match.attach(context: modelContext) }
    }
}
