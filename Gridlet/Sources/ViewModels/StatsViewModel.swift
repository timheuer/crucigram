import SwiftUI
import Observation

/// View model for the stats screen.
@Observable
final class StatsViewModel {
    private(set) var stats: PlayerStats

    init() {
        var s = PersistenceService.shared.loadPlayerStats()
        s.validateStreak()
        self.stats = s
    }

    func refresh() {
        var s = PersistenceService.shared.loadPlayerStats()
        s.validateStreak()
        self.stats = s
    }

    var formattedAverageTime: String {
        let total = Int(stats.averageCompletionTime)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
