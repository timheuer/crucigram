import SwiftUI

/// The crossword grid — renders all cells and handles tap interactions.
struct GridView: View {
    @Bindable var viewModel: PuzzleViewModel

    private var dim: Int { viewModel.puzzle.gridSize.dimension }

    var body: some View {
        let activeWordCells = Set(viewModel.activeWordCells)
        let selectedCell = viewModel.gameState.selectedCell

        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(0..<dim, id: \.self) { row in
                GridRow {
                    ForEach(0..<dim, id: \.self) { col in
                        let cellPos = CellPosition(row: row, col: col)
                        let isBlack = viewModel.puzzle.isBlackCell(row: row, col: col)

                        GridCellView(
                            row: row,
                            col: col,
                            letter: viewModel.gameState.playerGrid[row][col],
                            solutionLetter: viewModel.puzzle.solutionLetter(row: row, col: col),
                            isBlack: isBlack,
                            isSelected: selectedCell == cellPos,
                            isActiveWord: activeWordCells.contains(cellPos),
                            isWrong: viewModel.gameState.checkedWrongCells.contains(cellPos),
                            number: viewModel.cellNumber(row: row, col: col),
                            showSolution: viewModel.devMode
                        )
                        .onTapGesture {
                            if !isBlack {
                                viewModel.selectCell(row: row, col: col)
                            }
                        }
                    }
                }
            }
        }
        .border(Color.gray, width: 2)
        .padding(.horizontal, 8)
    }
}
