import Foundation

/// Manages the daily puzzle: deterministic generation from today's date, with caching.
final class DailyPuzzleService: @unchecked Sendable {
    private let generator: PuzzleGeneratorService
    private let persistence: PersistenceService

    init(generator: PuzzleGeneratorService = PuzzleGeneratorService(),
         persistence: PersistenceService = .shared) {
        self.generator = generator
        self.persistence = persistence
    }

    /// Today's date string in YYYY-MM-DD format (local time zone).
    var todayString: String {
        PlayerStats.todayString()
    }

    /// Get today's puzzle. Returns cached version if available, otherwise generates and caches it.
    /// Uses Apple Intelligence when available for word/clue generation.
    func todaysPuzzle() async -> PuzzleDefinition {
        let dateString = todayString

        // Check cache first
        if let cached = persistence.loadCachedDailyPuzzle(for: dateString) {
            return cached
        }

        // Generate using AI if available, otherwise fall back to bundled list
        let seed = PuzzleGeneratorService.seed(for: dateString)
        let puzzle = await generator.generateWithAI(seed: seed)

        // Cache for future use
        try? persistence.cacheDailyPuzzle(puzzle, for: dateString)
        persistence.pruneOldDailyCache()

        return puzzle
    }

    /// Synchronous version using bundled word list only (for fallback).
    func todaysPuzzleSync() -> PuzzleDefinition {
        let dateString = todayString

        if let cached = persistence.loadCachedDailyPuzzle(for: dateString) {
            return cached
        }

        let seed = PuzzleGeneratorService.seed(for: dateString)
        let puzzle = generator.generate(seed: seed)

        try? persistence.cacheDailyPuzzle(puzzle, for: dateString)
        persistence.pruneOldDailyCache()

        return puzzle
    }

    /// Check if a puzzle ID matches today's daily puzzle.
    func isTodaysPuzzle(id: UUID) -> Bool {
        let puzzle = todaysPuzzleSync()
        return puzzle.id == id
    }
}
