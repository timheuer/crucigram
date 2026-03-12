import SwiftUI

/// Renders a single cell in the crossword grid.
struct GridCellView: View {
  let row: Int
  let col: Int
  let letter: Character?
  let solutionLetter: Character?
  let isBlack: Bool
  let isSelected: Bool
  let isActiveWord: Bool
  let isWrong: Bool
  let number: Int?
  let showSolution: Bool
  let accessibilityLabel: String
  let accessibilityValue: String?
  let accessibilityHint: String?

  var body: some View {
    ZStack(alignment: .topLeading) {
      // Background
      Rectangle()
        .fill(backgroundColor)
        .border(Color.gray, width: 0.5)

      // Cell number
      if let number = number {
        Text("\(number)")
          .font(.system(size: 18, weight: .semibold, design: .rounded))
          .foregroundStyle(Color.black.opacity(0.7))
          .padding(2)
      }

      // Dev mode: dimmed solution letter (shown when no player letter)
      if showSolution, letter == nil, let solution = solutionLetter {
        Text(String(solution))
          .font(.system(size: 28, weight: .regular, design: .rounded))
          .foregroundStyle(Color.black.opacity(0.15))
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }

      // Player letter
      if let letter = letter {
        Text(String(letter))
          .font(.system(size: 28, weight: .semibold, design: .rounded))
          .foregroundStyle(Color.black)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }

      // Wrong letter overlay
      if isWrong {
        Rectangle()
          .fill(Color.red.opacity(0.3))
      }
    }
    .aspectRatio(1, contentMode: .fit)
    .contentShape(Rectangle())
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(accessibilityLabel)
    .accessibilityValue(accessibilityValue ?? "")
    .accessibilityHint(accessibilityHint ?? "")
    .accessibilityAddTraits(isBlack ? [] : .isButton)
  }

  private var backgroundColor: Color {
    if isBlack {
      return .black
    } else if isSelected {
      return Color(red: 1.0, green: 0.85, blue: 0.35)
    } else if isActiveWord {
      return Color(red: 0.73, green: 0.87, blue: 1.0)
    } else {
      return .white
    }
  }
}
