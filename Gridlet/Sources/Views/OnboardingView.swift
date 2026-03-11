import SwiftUI

/// First-run onboarding flow explaining how to play Gridlet.
struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "square.grid.3x3.fill",
            title: "Welcome to Gridlet",
            description: "A bite-sized crossword puzzle you can solve in minutes. Fill the grid with words that run across and down."
        ),
        OnboardingPage(
            icon: "hand.tap.fill",
            title: "Tap to Select",
            description: "Tap any cell to select it and see the clue. Tap the same cell again to switch between across and down."
        ),
        OnboardingPage(
            icon: "keyboard.fill",
            title: "Type to Fill",
            description: "Use the keyboard to enter letters. The cursor automatically advances to the next empty cell in the word."
        ),
        OnboardingPage(
            icon: "checkmark.circle.fill",
            title: "Check Your Work",
            description: "Tap Check to verify the currently selected word. Wrong letters are highlighted in red — fix them and try again."
        ),
        OnboardingPage(
            icon: "calendar.badge.clock",
            title: "Daily & Unlimited",
            description: "A new daily puzzle every day — keep your streak alive! Or play unlimited puzzles anytime for extra practice."
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    VStack(spacing: 24) {
                        Spacer()

                        Image(systemName: page.icon)
                            .font(.system(size: 64))
                            .foregroundStyle(Color.accentColor)

                        Text(page.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)

                        Text(page.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Spacer()
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            // Bottom button
            Button {
                if currentPage < pages.count - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    dismiss()
                }
            } label: {
                Text(currentPage < pages.count - 1 ? "Next" : "Let's Play!")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)

            if currentPage < pages.count - 1 {
                Button("Skip") {
                    dismiss()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 16)
            }
        }
    }
}

private struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

#Preview {
    OnboardingView()
}
