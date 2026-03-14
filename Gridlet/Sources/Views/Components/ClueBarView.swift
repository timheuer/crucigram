import SwiftUI

/// Displays the active clue text with previous/next word navigation.
struct ClueBarView: View {
  let clueLabel: String
  let clueText: String
  let accessibilityLabel: String
  let accessibilityValue: String
  let accessibilityHint: String
  let onPrevious: () -> Void
  let onNext: () -> Void
  let onToggleDirection: () -> Void

  private var hasClue: Bool { !clueLabel.isEmpty }

  var body: some View {
    HStack(spacing: 4) {
      previousButton
      clueButton
      nextButton
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .frame(height: 56)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    .padding(.horizontal, 8)
  }

  private var previousButton: some View {
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
  }

  private var nextButton: some View {
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

  private var clueContent: some View {
    Group {
      if hasClue {
        HStack(spacing: 6) {
          Text(clueLabel)
            .font(.subheadline.weight(.bold).monospacedDigit())
            .foregroundStyle(Color.accentColor)
          Text(clueText)
            .font(.subheadline)
            .foregroundStyle(.primary)
            .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
      } else {
        Text("Tap a cell to see its clue")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
      }
    }
  }

  private var clueButton: some View {
    Button(action: onToggleDirection) {
      clueContent
    }
    .buttonStyle(.plain)
    .accessibilityLabel(accessibilityLabel)
    .accessibilityValue(accessibilityValue)
    .accessibilityHint(accessibilityHint)
  }
}
