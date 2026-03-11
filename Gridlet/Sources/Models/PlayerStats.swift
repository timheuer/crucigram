import Foundation

/// A record of a single completed puzzle.
struct CompletionRecord: Codable, Identifiable, Sendable {
    let id: UUID
    let puzzleId: UUID
    let date: Date
    let elapsedSeconds: TimeInterval
    let gridSize: GridSize
    let checksUsed: Int
    let isDaily: Bool

    init(
        id: UUID = UUID(),
        puzzleId: UUID,
        date: Date = Date(),
        elapsedSeconds: TimeInterval,
        gridSize: GridSize,
        checksUsed: Int,
        isDaily: Bool
    ) {
        self.id = id
        self.puzzleId = puzzleId
        self.date = date
        self.elapsedSeconds = elapsedSeconds
        self.gridSize = gridSize
        self.checksUsed = checksUsed
        self.isDaily = isDaily
    }
}

/// Aggregated player statistics persisted across sessions.
struct PlayerStats: Codable, Sendable {
    var currentStreak: Int
    var longestStreak: Int
    var lastDailyCompletedDate: String?  // "YYYY-MM-DD" format
    var totalPuzzlesSolved: Int
    var totalDailySolved: Int
    var completionHistory: [CompletionRecord]

    /// Average completion time across all solved puzzles.
    var averageCompletionTime: TimeInterval {
        guard !completionHistory.isEmpty else { return 0 }
        let total = completionHistory.reduce(0.0) { $0 + $1.elapsedSeconds }
        return total / Double(completionHistory.count)
    }

    init() {
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastDailyCompletedDate = nil
        self.totalPuzzlesSolved = 0
        self.totalDailySolved = 0
        self.completionHistory = []
    }

    /// Today's date string in YYYY-MM-DD format.
    static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: Date())
    }

    /// Yesterday's date string in YYYY-MM-DD format.
    static func yesterdayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        return formatter.string(from: yesterday)
    }

    /// Record a daily puzzle completion and update streak.
    mutating func recordDailyCompletion(record: CompletionRecord) {
        completionHistory.append(record)
        totalPuzzlesSolved += 1
        totalDailySolved += 1

        let today = Self.todayString()
        let yesterday = Self.yesterdayString()

        if lastDailyCompletedDate == yesterday || lastDailyCompletedDate == today {
            currentStreak += 1
        } else {
            currentStreak = 1
        }

        longestStreak = max(longestStreak, currentStreak)
        lastDailyCompletedDate = today
    }

    /// Record an unlimited puzzle completion (no streak impact).
    mutating func recordUnlimitedCompletion(record: CompletionRecord) {
        completionHistory.append(record)
        totalPuzzlesSolved += 1
    }

    /// Check and reset streak if yesterday's daily was missed. Call on app launch.
    mutating func validateStreak() {
        let yesterday = Self.yesterdayString()
        let today = Self.todayString()

        if let last = lastDailyCompletedDate,
           last != yesterday && last != today {
            currentStreak = 0
        }
    }
}
