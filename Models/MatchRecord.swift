import Foundation
import SwiftData

@Model
final class MatchRecord {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var title: String
    var rallyCount: Int
    var clipPaths: [String]

    init(title: String = "Padel match") {
        self.id = UUID()
        self.startedAt = .now
        self.endedAt = nil
        self.title = title
        self.rallyCount = 0
        self.clipPaths = []
    }

    var durationText: String {
        let end = endedAt ?? .now
        let seconds = max(0, Int(end.timeIntervalSince(startedAt)))
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
