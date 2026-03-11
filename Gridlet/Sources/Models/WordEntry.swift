import Foundation

/// A word placed in the puzzle grid, along with its clue.
struct WordEntry: Codable, Identifiable, Sendable, Equatable {
    let id: UUID
    let direction: WordDirection
    let text: String
    let clue: String
    let startRow: Int
    let startCol: Int

    /// Number of letters in the word.
    var length: Int { text.count }

    /// The grid positions this word occupies, in order.
    var cells: [(row: Int, col: Int)] {
        (0..<length).map { offset in
            switch direction {
            case .across:
                return (row: startRow, col: startCol + offset)
            case .down:
                return (row: startRow + offset, col: startCol)
            }
        }
    }

    init(
        id: UUID = UUID(),
        direction: WordDirection,
        text: String,
        clue: String,
        startRow: Int,
        startCol: Int
    ) {
        self.id = id
        self.direction = direction
        self.text = text
        self.clue = clue
        self.startRow = startRow
        self.startCol = startCol
    }
}
