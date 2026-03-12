import SwiftUI

/// Stats display screen showing streaks, times, and history.
struct StatsView: View {
  @State private var viewModel = StatsViewModel()

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        // Streak hero card
        streakCard

        // Quick stats grid
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
          StatCard(
            icon: "puzzlepiece.fill",
            iconColor: .blue,
            title: "Solved",
            value: "\(viewModel.stats.totalPuzzlesSolved)"
          )
          StatCard(
            icon: "calendar.circle.fill",
            iconColor: .purple,
            title: "Daily Solved",
            value: "\(viewModel.stats.totalDailySolved)"
          )
          StatCard(
            icon: "clock.fill",
            iconColor: .teal,
            title: "Avg Time",
            value: viewModel.formattedAverageTime
          )
          if let best = viewModel.formattedBestTime {
            StatCard(
              icon: "bolt.fill",
              iconColor: .yellow,
              title: "Best Time",
              value: best
            )
          }
        }

        // Accuracy card
        if viewModel.stats.totalPuzzlesSolved > 0 {
          accuracyCard
        }
      }
      .padding()
    }
    .navigationTitle("Stats")
    .onAppear { viewModel.refresh() }
  }

  // MARK: - Streak Card

  private var streakCard: some View {
    HStack(spacing: 16) {
      VStack(spacing: 4) {
        Text(viewModel.stats.currentStreak > 0 ? "🔥" : "💤")
          .font(.system(size: 44))
        Text("\(viewModel.stats.currentStreak)")
          .font(.system(size: 36, weight: .heavy, design: .rounded))
        Text("day streak")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      .frame(maxWidth: .infinity)

      Divider()
        .frame(height: 60)

      VStack(spacing: 4) {
        Text("🏆")
          .font(.system(size: 44))
        Text("\(viewModel.stats.longestStreak)")
          .font(.system(size: 36, weight: .heavy, design: .rounded))
        Text("longest")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      .frame(maxWidth: .infinity)
    }
    .padding(20)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(
      "Current streak \(viewModel.stats.currentStreak) days. Longest streak \(viewModel.stats.longestStreak) days."
    )
  }

  // MARK: - Accuracy Card

  private var accuracyCard: some View {
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 4) {
        Label("No-check solves", systemImage: "checkmark.seal.fill")
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(.green)
        Text("\(viewModel.noCheckPuzzles) of \(viewModel.stats.totalPuzzlesSolved) puzzles")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()

      Text("\(viewModel.noCheckPuzzles)")
        .font(.system(size: 32, weight: .heavy, design: .rounded))
        .foregroundStyle(.green)
    }
    .padding(16)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("No-check solves")
    .accessibilityValue(
      "\(viewModel.noCheckPuzzles) of \(viewModel.stats.totalPuzzlesSolved) puzzles")
  }
}

// MARK: - Stat Card

private struct StatCard: View {
  let icon: String
  let iconColor: Color
  let title: String
  let value: String

  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundStyle(iconColor)
        .accessibilityHidden(true)

      Text(value)
        .font(.system(size: 24, weight: .bold, design: .rounded))

      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(title)
    .accessibilityValue(value)
  }
}
