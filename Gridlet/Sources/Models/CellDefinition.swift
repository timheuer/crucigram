import Foundation

/// A single cell in the puzzle grid.
struct CellDefinition: Codable, Sendable, Equatable {
    let row: Int
    let col: Int

    /// The solution letter for this cell. `nil` means the cell is a black (blocked) cell.
    let letter: Character?

    enum CodingKeys: String, CodingKey {
        case row, col, letter
    }

    init(row: Int, col: Int, letter: Character?) {
        self.row = row
        self.col = col
        self.letter = letter
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        row = try container.decode(Int.self, forKey: .row)
        col = try container.decode(Int.self, forKey: .col)
        if let str = try container.decodeIfPresent(String.self, forKey: .letter) {
            letter = str.first
        } else {
            letter = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(row, forKey: .row)
        try container.encode(col, forKey: .col)
        try container.encode(letter.map { String($0) }, forKey: .letter)
    }
}
