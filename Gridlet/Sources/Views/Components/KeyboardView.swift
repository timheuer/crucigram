import SwiftUI

/// Custom QWERTY keyboard for letter input.
struct KeyboardView: View {
    let onLetter: (Character) -> Void
    let onBackspace: () -> Void

    private struct KeyRow: Identifiable {
        let id: Int
        let keys: [String]
        let isBottomRow: Bool
    }

    private var keyRows: [KeyRow] {
        [
            KeyRow(id: 0, keys: ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], isBottomRow: false),
            KeyRow(id: 1, keys: ["A", "S", "D", "F", "G", "H", "J", "K", "L"], isBottomRow: false),
            KeyRow(id: 2, keys: ["Z", "X", "C", "V", "B", "N", "M"], isBottomRow: true),
        ]
    }

    var body: some View {
        VStack(spacing: 8) {
            keyboardRow(keys: ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], isBottom: false)
            keyboardRow(keys: ["A", "S", "D", "F", "G", "H", "J", "K", "L"], isBottom: false)
            keyboardRow(keys: ["Z", "X", "C", "V", "B", "N", "M"], isBottom: true)
        }
        .padding(.horizontal, 6)
        .padding(.bottom, 6)
    }

    private func keyboardRow(keys: [String], isBottom: Bool) -> some View {
        HStack(spacing: 5) {
            if isBottom {
                Spacer(minLength: 0)
            }

            ForEach(keys, id: \.self) { key in
                Button {
                    onLetter(Character(key))
                } label: {
                    Text(key)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Letter \(key)")
            }

            if isBottom {
                Button {
                    onBackspace()
                } label: {
                    Image(systemName: "delete.backward")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 50, height: 46)
                        .background(Color(.systemGray4))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Backspace")

                Spacer(minLength: 0)
            }
        }
    }
}
