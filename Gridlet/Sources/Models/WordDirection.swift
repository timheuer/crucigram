import Foundation

/// Word direction within the grid.
enum WordDirection: String, Codable, Sendable {
    case across
    case down

    /// Toggle to the other direction.
    var toggled: WordDirection {
        self == .across ? .down : .across
    }
}
