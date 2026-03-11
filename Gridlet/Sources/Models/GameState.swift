import Foundation

/// A position in the grid.
struct CellPosition: Codable, Hashable, Sendable {
    let row: Int
    let col: Int
}

/// Tracks the player's progress on a single puzzle.
struct GameState: Codable, Sendable {
    let puzzleId: UUID
    let isDaily: Bool

    /// The player's current letter entries. `nil` means the cell is empty (or black).
    var playerGrid: [[Character?]]

    /// The currently selected cell, if any.
    var selectedCell: CellPosition?

    /// The active input direction.
    var activeDirection: WordDirection

    /// Cells that were marked wrong by the Check function.
    var checkedWrongCells: Set<CellPosition>

    /// Whether the puzzle has been completed (all cells correct).
    var isCompleted: Bool

    /// When the player started this puzzle.
    let startedAt: Date

    /// When the puzzle was completed, if applicable.
    var completedAt: Date?

    /// Elapsed seconds of active play (paused time excluded).
    var elapsedSeconds: TimeInterval

    /// Number of times the player used Check.
    var checksUsed: Int

    init(puzzleId: UUID, isDaily: Bool, gridSize: GridSize) {
        self.puzzleId = puzzleId
        self.isDaily = isDaily
        let dim = gridSize.dimension
        self.playerGrid = Array(repeating: Array(repeating: nil as Character?, count: dim), count: dim)
        self.selectedCell = nil
        self.activeDirection = .across
        self.checkedWrongCells = []
        self.isCompleted = false
        self.startedAt = Date()
        self.completedAt = nil
        self.elapsedSeconds = 0
        self.checksUsed = 0
    }

    // MARK: - Codable for Character? grid and Set<CellPosition>

    enum CodingKeys: String, CodingKey {
        case puzzleId, isDaily, playerGrid, selectedCell, activeDirection
        case checkedWrongCells, isCompleted, startedAt, completedAt
        case elapsedSeconds, checksUsed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        puzzleId = try container.decode(UUID.self, forKey: .puzzleId)
        isDaily = try container.decode(Bool.self, forKey: .isDaily)

        let stringGrid = try container.decode([[String?]].self, forKey: .playerGrid)
        playerGrid = stringGrid.map { row in row.map { $0?.first } }

        selectedCell = try container.decodeIfPresent(CellPosition.self, forKey: .selectedCell)
        activeDirection = try container.decode(WordDirection.self, forKey: .activeDirection)

        let wrongCellsArray = try container.decode([CellPosition].self, forKey: .checkedWrongCells)
        checkedWrongCells = Set(wrongCellsArray)

        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        startedAt = try container.decode(Date.self, forKey: .startedAt)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        elapsedSeconds = try container.decode(TimeInterval.self, forKey: .elapsedSeconds)
        checksUsed = try container.decode(Int.self, forKey: .checksUsed)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(puzzleId, forKey: .puzzleId)
        try container.encode(isDaily, forKey: .isDaily)

        let stringGrid = playerGrid.map { row in row.map { $0.map { String($0) } } }
        try container.encode(stringGrid, forKey: .playerGrid)

        try container.encodeIfPresent(selectedCell, forKey: .selectedCell)
        try container.encode(activeDirection, forKey: .activeDirection)
        try container.encode(Array(checkedWrongCells), forKey: .checkedWrongCells)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(startedAt, forKey: .startedAt)
        try container.encodeIfPresent(completedAt, forKey: .completedAt)
        try container.encode(elapsedSeconds, forKey: .elapsedSeconds)
        try container.encode(checksUsed, forKey: .checksUsed)
    }
}
