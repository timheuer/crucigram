import SwiftUI

/// Displays the active clue text with previous/next word navigation.
struct ClueBarView: View {
  let clueText: String
  let accessibilityLabel: String
  let accessibilityValue: String
  let accessibilityHint: String
  let onPrevious: () -> Void
  let onNext: () -> Void
  let onToggleDirection: () -> Void

  var body: some View {
    HStack(spacing: 4) {
      Button(action: onPrevious) {
        Image(systemName: "chevron.left")
          .font(.body.weight(.semibold))
          .frame(width: 36, height: 44)
          .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .foregroundStyle(Color.accentColor)
      .accessibilityLabel("Previous clue")
      .accessibilityHint("Moves to the previous word in the puzzle.")

      Button(action: onToggleDirection) {
        Text(clueText.isEmpty ? "Tap a cell to see its clue" : clueText)
          .font(.subheadline)
          .foregroundStyle(clueText.isEmpty ? .secondary : .primary)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
          .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
      }
      .buttonStyle(.plain)
      .accessibilityLabel(accessibilityLabel)
      .accessibilityValue(accessibilityValue)
      .accessibilityHint(accessibilityHint)

      Button(action: onNext) {
        Image(systemName: "chevron.right")
          .font(.body.weight(.semibold))
          .frame(width: 36, height: 44)
          .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .foregroundStyle(Color.accentColor)
      .accessibilityLabel("Next clue")
      .accessibilityHint("Moves to the next word in the puzzle.")
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .frame(height: 56)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    .padding(.horizontal, 8)
  }
}
