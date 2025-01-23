//
//  GameView.swift
//  TileAndError
//
//  Created by Abdullah Khan on 1/15/25.
//

import SwiftUI


// MARK: - Main Game View
struct GameView: View {
    @State private var model = BlockGameModel()
    @State private var blocks: [BlockState] = Self.randomThreeBlocks()
    @State private var gridRect: CGRect = .zero
    @State private var score: Int = 0
    @AppStorage("HighestScore") private var highestScore = 0
    @State private var gameOver: Bool = false
    @State private var hoverShape: [[Int]]? = nil
    @State private var hoverPosition: CGPoint? = nil
    @State private var comboMessage: String? = nil
    @State private var showComboMessage: Bool = false
    @State private var lastClearTime: Date? = nil // Tracks last clear time for combos

    let gridCellSize: CGFloat = 45
    let blockCellSize: CGFloat = 40

    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 20) {
                // Scoreboard
                HStack {
                    Text("High Score: \(highestScore)")
                        .font(.title2)
                    Spacer()
                    Text("Score: \(score)")
                        .font(.title2)
                }
                .padding(.horizontal)

                // Game Grid
                ZStack(alignment: .topLeading) {
                    gridView
                        .frame(width: gridCellSize * 8, height: gridCellSize * 8)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        gridRect = geo.frame(in: .global)
                                    }
                                    .onChange(of: geo.size) { _ in
                                        gridRect = geo.frame(in: .global)
                                    }
                            }
                        )

                    if let hoverShape = hoverShape, let hoverPosition = hoverPosition {
                        hoverIndicator(for: hoverShape, at: hoverPosition)
                    }
                }

                // Blocks to Place
                HStack(alignment: .bottom, spacing: 40) {
                    ForEach(blocks) { block in
                        if !block.isPlaced {
                            SingleBlockContainer(
                                block: block,
                                cellSize: blockCellSize,
                                onHover: { shape, globalPosition in
                                    hoverShape = shape
                                    hoverPosition = globalPosition
                                },
                                onDrop: { shape, finalGlobal in
                                    let success = placeBlockIfValid(shape, dropLocation: finalGlobal)
                                    if success {
                                        if let idx = blocks.firstIndex(where: { $0.id == block.id }) {
                                            blocks[idx].isPlaced = true
                                        }
                                        checkAllBlocksPlaced()
                                        clearFullRowsAndColumns()
                                        checkGameOver()
                                    }
                                    hoverShape = nil
                                    hoverPosition = nil
                                    return success
                                }
                            )
                        }
                    }
                }
            }
            .padding()
            .alert("Game Over", isPresented: $gameOver) {
                Button("New Game") {
                    startNewGame()
                }
            } message: {
                Text("No more moves available!\nYour final score: \(score)")
            }

            // Display Combo Message
            if showComboMessage, let comboMessage = comboMessage {
                Text(comboMessage)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .transition(.opacity)
                    .zIndex(1) // Ensure this appears on top of other elements
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showComboMessage = false
                        }
                    }
            }
        }
    }

    // MARK: - Game Grid with Original Appearance
    private var gridView: some View {
        VStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { col in
                        if let color = model.grid[row][col] {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [color.opacity(0.8), color]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: gridCellSize, height: gridCellSize)
                                .cornerRadius(8)
                                .shadow(color: color.opacity(0.5), radius: 4, x: 2, y: 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(color.opacity(0.9), lineWidth: 2)
                                )
                        } else {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: gridCellSize, height: gridCellSize)
                                .cornerRadius(4)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                                .border(Color.black, width: 1)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Hover Indicator
    private func hoverIndicator(for shape: [[Int]], at position: CGPoint) -> some View {
        let localX = position.x - gridRect.minX
        let localY = position.y - gridRect.minY
        let col = Int((localX / gridCellSize).rounded(.down))
        let row = Int((localY / gridCellSize).rounded(.down))
        let valid = isShapePlacementValid(shape, atRow: row, col: col)

        return ZStack {
            ForEach(0..<shape.count, id: \.self) { r in
                ForEach(0..<shape[r].count, id: \.self) { c in
                    if shape[r][c] == 1 {
                        let offsetX = CGFloat(col + c) * gridCellSize
                        let offsetY = CGFloat(row + r) * gridCellSize
                        if (0...7).contains(col + c), (0...7).contains(row + r) {
                            Rectangle()
                                .fill(valid ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                                .overlay(
                                    Rectangle()
                                        .stroke(valid ? Color.green : Color.red, lineWidth: 2)
                                )
                                .frame(width: gridCellSize, height: gridCellSize)
                                .offset(x: offsetX, y: offsetY)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Clear Rows and Columns
    private func clearFullRowsAndColumns() {
        var clearedRows = Set<Int>()
        var clearedCols = Set<Int>()

        // Identify full rows
        for row in 0..<8 {
            if model.grid[row].allSatisfy({ $0 != nil }) {
                clearedRows.insert(row)
            }
        }

        // Identify full columns
        for col in 0..<8 {
            let columnCells = model.grid.map { $0[col] }
            if columnCells.allSatisfy({ $0 != nil }) {
                clearedCols.insert(col)
            }
        }

        let totalClears = clearedRows.count + clearedCols.count

        if totalClears > 1 {
            comboMessage = "Combo \(totalClears)x!"
            showComboMessage = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showComboMessage = false
            }
        }

        // Clear rows and columns
        for row in clearedRows {
            for col in 0..<8 {
                model.grid[row][col] = nil
            }
        }
        for col in clearedCols {
            for row in 0..<8 {
                model.grid[row][col] = nil
            }
        }

        score += totalClears * 100
    }

    // MARK: - Placement Validations
    private func isShapePlacementValid(_ shape: [[Int]], atRow row: Int, col: Int) -> Bool {
        for r in 0..<shape.count {
            for c in 0..<shape[r].count {
                if shape[r][c] == 1 {
                    let rr = row + r
                    let cc = col + c
                    if rr < 0 || rr >= 8 || cc < 0 || cc >= 8 || model.grid[rr][cc] != nil {
                        return false
                    }
                }
            }
        }
        return true
    }

    private func placeBlockIfValid(_ shape: [[Int]], dropLocation: CGPoint) -> Bool {
        let localX = dropLocation.x - gridRect.minX
        let localY = dropLocation.y - gridRect.minY
        let col = Int((localX / gridCellSize).rounded(.down))
        let row = Int((localY / gridCellSize).rounded(.down))
        guard isShapePlacementValid(shape, atRow: row, col: col) else {
            return false
        }
        for r in 0..<shape.count {
            for c in 0..<shape[r].count {
                if shape[r][c] == 1 {
                    model.grid[row + r][col + c] = blocks.first { $0.shape == shape }?.color
                }
            }
        }
        return true
    }

    private func checkAllBlocksPlaced() {
        if blocks.allSatisfy({ $0.isPlaced }) {
            blocks = Self.randomThreeBlocks()
        }
    }

    private func checkGameOver() {
        for block in blocks where !block.isPlaced {
            if canPlaceBlockAnywhere(block.shape) {
                return
            }
        }
        gameOver = true
        highestScore = max(highestScore, score)
    }

    private func canPlaceBlockAnywhere(_ shape: [[Int]]) -> Bool {
        for row in 0..<8 {
            for col in 0..<8 {
                if isShapePlacementValid(shape, atRow: row, col: col) {
                    return true
                }
            }
        }
        return false
    }

    private func startNewGame() {
        model = BlockGameModel()
        score = 0
        blocks = Self.randomThreeBlocks()
        gameOver = false
        lastClearTime = nil
    }

    static func randomThreeBlocks() -> [BlockState] {
        let rawShapes: [[[Int]]] = [
            [[1, 1], [1, 1]],
            [[1, 1], [1, 0]],
            [[1, 1, 1]],
            [[1, 1, 1], [0, 1, 0]],
            [[1, 0], [1, 0], [1, 1]],
            [[0, 1, 0], [1, 1, 1]],
            [[1, 1, 1], [1, 1, 1], [1, 1, 1]]
        ]
        let colors: [Color] = [.red, .blue, .green, .orange, .purple, .yellow, .pink]
        var blocks = [BlockState]()
        for _ in 0..<3 {
            if let shape = rawShapes.randomElement(), let color = colors.randomElement() {
                let trimmed = trimShape(shape)
                blocks.append(BlockState(shape: trimmed, color: color))
            }
        }
        return blocks
    }

    private static func trimShape(_ shape: [[Int]]) -> [[Int]] {
        let rows = shape.count
        guard rows > 0 else { return [[]] }
        let cols = shape[0].count

        var minR = rows
        var maxR = -1
        var minC = cols
        var maxC = -1

        for r in 0..<rows {
            for c in 0..<cols {
                if shape[r][c] == 1 {
                    minR = min(minR, r)
                    maxR = max(maxR, r)
                    minC = min(minC, c)
                    maxC = max(maxC, c)
                }
            }
        }

        if maxR == -1 {
            return [[0]]
        }

        var result = [[Int]]()
        for r in minR...maxR {
            let slice = shape[r][minC...maxC]
            result.append(Array(slice))
        }
        return result
    }
}
