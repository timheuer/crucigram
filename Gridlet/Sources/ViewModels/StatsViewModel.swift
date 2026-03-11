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
        formatTime(stats.averageCompletionTime)
    }

    var formattedBestTime: String? {
        guard let best = stats.completionHistory.min(by: { $0.elapsedSeconds < $1.elapsedSeconds }) else {
            return nil
        }
        return formatTime(best.elapsedSeconds)
    }

    var totalChecksUsed: Int {
        stats.completionHistory.reduce(0) { $0 + $1.checksUsed }
    }

    var noCheckPuzzles: Int {
        stats.completionHistory.filter { $0.checksUsed == 0 }.count
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
