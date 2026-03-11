import SwiftUI

/// Stats display screen showing streaks, times, and history.
struct StatsView: View {
    @State private var viewModel = StatsViewModel()

    var body: some View {
        List {
            Section("Streak") {
                StatRow(label: "Current Streak", value: "\(viewModel.stats.currentStreak)")
                StatRow(label: "Longest Streak", value: "\(viewModel.stats.longestStreak)")
            }

            Section("Totals") {
                StatRow(label: "Puzzles Solved", value: "\(viewModel.stats.totalPuzzlesSolved)")
                StatRow(label: "Daily Solved", value: "\(viewModel.stats.totalDailySolved)")
                StatRow(label: "Average Time", value: viewModel.formattedAverageTime)
            }

        }
        .navigationTitle("Stats")
        .onAppear { viewModel.refresh() }
    }
}

private struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
    }
}
