import SwiftUI

/// The main puzzle-solving screen combining grid, clue bar, and keyboard.
struct PuzzleView: View {
    @Bindable var viewModel: PuzzleViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var timerTask: Task<Void, Never>?
    @State private var showCompletion = false
    @State private var showDevInfo = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with timer and check button
            headerBar
                .frame(height: 44)

            Spacer(minLength: 8)

            // Crossword grid
            GridView(viewModel: viewModel)

            Spacer(minLength: 8)

            // Clue bar with prev/next navigation — fixed height
            ClueBarView(
                clueText: viewModel.activeClue,
                onPrevious: { viewModel.selectPreviousWord() },
                onNext: { viewModel.selectNextWord() },
                onToggleDirection: { toggleDirection() }
            )

            Spacer(minLength: 8)

            // Keyboard
            if !viewModel.isCompleted {
                KeyboardView(
                    onLetter: { letter in
                        viewModel.enterLetter(letter)
                        checkForCompletion()
                    },
                    onBackspace: {
                        viewModel.backspace()
                    }
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isCompleted)
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .overlay {
            if showCompletion {
                completionOverlay
            }
        }
        .sheet(isPresented: $showDevInfo) {
            DevInfoView(viewModel: viewModel)
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            // Timer
            Text(formattedTime)
                .font(.system(.body, design: .rounded).monospacedDigit())
                .foregroundStyle(.secondary)

            Spacer()

            if viewModel.devMode {
                Button {
                    viewModel.devMode.toggle()
                } label: {
                    Image(systemName: "eye.fill")
                        .foregroundStyle(.orange)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button {
                    showDevInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.orange)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            if !viewModel.isCompleted {
                Button("Check") {
                    viewModel.checkActiveWord()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(viewModel.gameState.selectedCell == nil)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    // MARK: - Completion Overlay

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)

                Text("Puzzle Complete!")
                    .font(.title.bold())

                Text("Time: \(formattedTime)")
                    .font(.title3)

                if viewModel.gameState.checksUsed > 0 {
                    Text("Checks used: \(viewModel.gameState.checksUsed)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 8)
            }
            .padding(32)
            .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding(32)
        }
        .transition(.opacity)
    }

    // MARK: - Helpers

    private var formattedTime: String {
        let total = Int(viewModel.gameState.elapsedSeconds)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func toggleDirection() {
        if let cell = viewModel.gameState.selectedCell {
            viewModel.selectCell(row: cell.row, col: cell.col)
        }
    }

    private func checkForCompletion() {
        if viewModel.isCompleted && !showCompletion {
            withAnimation(.easeInOut(duration: 0.5)) {
                showCompletion = true
            }
        }
    }

    private func startTimer() {
        timerTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if !Task.isCancelled {
                    viewModel.addElapsedTime(1)
                }
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}
