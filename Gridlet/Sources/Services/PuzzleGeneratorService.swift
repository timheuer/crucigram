import Foundation
import GameplayKit
import CryptoKit

/// Generates PuzzleDefinition instances from a seed.
/// Uses Apple Intelligence for word/clue generation when available,
/// falls back to the bundled word list.
final class PuzzleGeneratorService: @unchecked Sendable {
    /// Golden-ratio stride used to deterministically perturb layout seeds across retries.
    private static let layoutSeedStride: UInt64 = 0x9E3779B97F4A7C15
    private static let maxLayoutSeedAttempts = 4

    private let wordListService: WordListService
    private let aiWordService: AIWordService
    private func minimumWords(for gridSize: GridSize) -> Int {
        gridSize == .six ? 8 : 6
    }

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

        // Get AI-generated words and diagnostics
        let generationResult = await aiWordService.generateWordClues(count: 40, maxLength: dim, seed: seed)
        let wordClues = generationResult.words

        // Build the puzzle using AI words, with clue lookup from AI results
        let words = wordClues.map { $0.word.uppercased() }
        let aiClues = Dictionary(wordClues.map { ($0.word.uppercased(), $0.clue) }, uniquingKeysWith: { first, _ in first })

        let puzzle = generateFromWords(
            words,
            seed: seed,
            gridSize: gridSize,
            aiGenerationStatus: generationResult.status,
            aiGenerationDetail: generationResult.detail,
            clueLookup: { word in
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
        aiGenerationStatus: AIGenerationStatus = .fallbackReasonUnknown,
        aiGenerationDetail: String? = nil,
        clueLookup: ((String) -> String)? = nil
    ) -> PuzzleDefinition {
        let dim = gridSize.dimension
        let lookup = clueLookup ?? { self.wordListService.clue(for: $0) }
        let minWords = minimumWords(for: gridSize)

        let result = runLayoutAttempts(words: words, seed: seed, dim: dim, minWords: minWords)

        // If we fell short of the minimum, supplement with bundled words and retry
        if result.placed.count < minWords {
            let existingWords = Set(words.map { $0.uppercased() })
            let extra = wordListService.words(maxLength: dim)
                .filter { !existingWords.contains($0.uppercased()) }
            let combined = words + extra
            let retryResult = runLayoutAttempts(words: combined, seed: seed, dim: dim, minWords: minWords)

            if retryResult.placed.count > result.placed.count {
                return buildPuzzle(
                    seed: seed,
                    gridSize: gridSize,
                    placed: retryResult.placed,
                    grid: retryResult.grid,
                    aiGenerationStatus: aiGenerationStatus,
                    aiGenerationDetail: aiGenerationDetail,
                    clueLookup: lookup
                )
            }
        }

        return buildPuzzle(
            seed: seed,
            gridSize: gridSize,
            placed: result.placed,
            grid: result.grid,
            aiGenerationStatus: aiGenerationStatus,
            aiGenerationDetail: aiGenerationDetail,
            clueLookup: lookup
        )
    }

    private struct LayoutResult {
        let placed: [CrosswordLayoutGenerator.PlacedWord]
        let grid: [[Character?]]
        let filledCells: Int
    }

    private func runLayoutAttempts(words: [String], seed: UInt64, dim: Int, minWords: Int) -> LayoutResult {
        var bestPlaced: [CrosswordLayoutGenerator.PlacedWord] = []
        var bestGrid: [[Character?]] = []
        var bestFilledCells = -1

        for attemptIndex in 0..<Self.maxLayoutSeedAttempts {
            let layoutSeed = seed &+ (UInt64(attemptIndex) &* Self.layoutSeedStride)
            let generator = CrosswordLayoutGenerator(columns: dim, rows: dim, seed: layoutSeed)
            generator.generate(words: words, minimumWordCount: minWords)

            let grid = generator.gridLetters()
            let filledCells = grid.flatMap { $0 }.compactMap { $0 }.count

            if bestGrid.isEmpty ||
                generator.result.count > bestPlaced.count ||
                (generator.result.count == bestPlaced.count && filledCells > bestFilledCells) {
                bestPlaced = generator.result
                bestGrid = grid
                bestFilledCells = filledCells
            }

            let bestDensity = Double(bestFilledCells) / Double(dim * dim)
            if bestPlaced.count >= minWords &&
                bestDensity >= CrosswordLayoutGenerator.targetDensityThreshold {
                break
            }
        }

        return LayoutResult(placed: bestPlaced, grid: bestGrid, filledCells: bestFilledCells)
    }

    private func buildPuzzle(
        seed: UInt64,
        gridSize: GridSize,
        placed: [CrosswordLayoutGenerator.PlacedWord],
        grid: [[Character?]],
        aiGenerationStatus: AIGenerationStatus = .fallbackReasonUnknown,
        aiGenerationDetail: String? = nil,
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
            words: words,
            isAIGenerated: aiGenerationStatus.isAIGenerated,
            aiGenerationStatus: aiGenerationStatus,
            aiGenerationDetail: aiGenerationDetail
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
