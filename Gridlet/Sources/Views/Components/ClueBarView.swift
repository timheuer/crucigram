import SwiftUI

/// Displays the active clue text with previous/next word navigation.
struct ClueBarView: View {
    let clueText: String
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

            Button(action: onToggleDirection) {
                Text(clueText.isEmpty ? "Tap a cell to see its clue" : clueText)
                    .font(.subheadline)
                    .foregroundStyle(clueText.isEmpty ? .secondary : .primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.accentColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(height: 56)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 8)
    }
}
