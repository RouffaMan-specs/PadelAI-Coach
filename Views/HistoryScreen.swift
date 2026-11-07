import SwiftUI
import SwiftData

struct HistoryScreen: View {
    @Query(sort: \MatchRecord.startedAt, order: .reverse) private var matches: [MatchRecord]

    var body: some View {
        NavigationStack {
            List {
                if matches.isEmpty {
                    ContentUnavailableView("No matches yet",
                                           systemImage: "tennisball",
                                           description: Text("Your recorded matches will appear here."))
                }
                ForEach(matches) { match in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(match.title).font(.headline)
                        Text(match.startedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption).foregroundStyle(.secondary)
                        HStack {
                            Label("\(match.rallyCount) rallies", systemImage: "video")
                            Spacer()
                            Text(match.durationText)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Match history")
        }
    }
}
