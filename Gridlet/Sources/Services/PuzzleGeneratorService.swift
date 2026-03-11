import Foundation
import GameplayKit
import CryptoKit

/// Generates PuzzleDefinition instances from a seed.
/// Uses Apple Intelligence for word/clue generation when available,
/// falls back to the bundled word list.
final class PuzzleGeneratorService: @unchecked Sendable {

    private let wordListService: WordListService
    private let aiWordService: AIWordService
    private let minimumWords = 4

    init(wordListService: WordListService = .shared,
         aiWordService: AIWordService = .shared) {
        self.wordListService = wordListService
        self.aiWordService = aiWordService
    }

    /// Generate a puzzle from a seed using the bundled word list (synchronous, deterministic).
    func generate(seed: UInt64) -> PuzzleDefinition {
        var rng = GKMersenneTwisterRandomSource(seed: seed)
        let gridSize: GridSize = rng.nextInt(upperBound: 2) == 0 ? .five : .six
        let dim = gridSize.dimension

        let allWords = wordListService.words(maxLength: dim)
        return generateFromWords(allWords, seed: seed, gridSize: gridSize)
    }

    /// Generate a puzzle using Apple Intelligence for word/clue generation (async).
    /// Falls back to bundled list if AI is unavailable.
    func generateWithAI(seed: UInt64) async -> PuzzleDefinition {
        var rng = GKMersenneTwisterRandomSource(seed: seed)
        let gridSize: GridSize = rng.nextInt(upperBound: 2) == 0 ? .five : .six
        let dim = gridSize.dimension

        // Get AI-generated words
        let wordClues = await aiWordService.generateWordClues(count: 80, maxLength: dim, seed: seed)

        // Build the puzzle using AI words, with clue lookup from AI results
        let words = wordClues.map { $0.word.uppercased() }
        let aiClues = Dictionary(wordClues.map { ($0.word.uppercased(), $0.clue) }, uniquingKeysWith: { first, _ in first })

        let puzzle = generateFromWords(words, seed: seed, gridSize: gridSize, clueLookup: { word in
            aiClues[word] ?? self.wordListService.clue(for: word)
        })
        return puzzle
    }

    /// Whether Apple Intelligence is available for word generation.
    var isAIAvailable: Bool { aiWordService.isAvailable }

    // MARK: - Core Generation

    private func generateFromWords(
        _ words: [String],
        seed: UInt64,
        gridSize: GridSize,
        clueLookup: ((String) -> String)? = nil
    ) -> PuzzleDefinition {
        let dim = gridSize.dimension
        let lookup = clueLookup ?? { self.wordListService.clue(for: $0) }

        // The generator itself handles multiple attempts and shuffling internally
        let generator = CrosswordLayoutGenerator(columns: dim, rows: dim, seed: seed)
        generator.generate(words: words)

        return buildPuzzle(seed: seed, gridSize: gridSize, placed: generator.result, grid: generator.gridLetters(), clueLookup: lookup)
    }

    private func buildPuzzle(
        seed: UInt64,
        gridSize: GridSize,
        placed: [CrosswordLayoutGenerator.PlacedWord],
        grid: [[Character?]],
        clueLookup: (String) -> String
    ) -> PuzzleDefinition {
        let dim = gridSize.dimension

        let cells: [[CellDefinition]] = (0..<dim).map { row in
            (0..<dim).map { col in
                CellDefinition(row: row, col: col, letter: grid[row][col])
            }
        }

        let words: [WordEntry] = placed.map { pw in
            WordEntry(
                direction: pw.direction,
                text: pw.word,
                clue: clueLookup(pw.word),
                startRow: pw.row - 1,
                startCol: pw.column - 1
            )
        }

        return PuzzleDefinition(
            seed: seed,
            gridSize: gridSize,
            cells: cells,
            words: words
        )
    }

    // MARK: - Daily Puzzle Seed

    /// Deterministic seed from a date string. Same date always produces the same seed.
    static func seed(for dateString: String) -> UInt64 {
        let input = "com.timheuer.gridlet:\(dateString)"
        let hash = SHA256.hash(data: Data(input.utf8))
        let bytes = Array(hash)
        var value: UInt64 = 0
        for i in 0..<8 {
            value |= UInt64(bytes[i]) << (i * 8)
        }
        return value
    }
}
