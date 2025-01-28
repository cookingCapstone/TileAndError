////
////  GameView.swift
////  TileAndError
////
////  Created by Abdullah Khan on 1/15/25.
////
//
import SwiftUI


//struct GameLogic: View {
    struct GameView: View {
        
//
        @State private var model = BlockGameModel()
        @State private var blocks: [BlockState] = Self.randomThreeBlocks()
        @State private var gridRect: CGRect = .zero
        @State private var score: Int = 0
        @AppStorage("HighestScore") private var highestScore = 0
        @State private var gameOver: Bool = false // Controls game over logic
        @State private var showGameOverView: Bool = false // Tracks whether to show GameOverView
        @State private var hoverShape: [[Int]]? = nil
        @State private var hoverPosition: CGPoint? = nil
        
        // Popup states for block placement and row/column clearance
        @State private var blockPopupText: String = ""
        @State private var showBlockPopup: Bool = false
        @State private var blockPopupPosition: CGPoint = .zero
        
        @State private var clearPopupText: String = ""
        @State private var showClearPopup: Bool = false
        @State private var clearPopupPosition: CGPoint = .zero
        
        let gridCellSize: CGFloat = 45
        let blockCellSize: CGFloat = 40
        
        var body: some View {
            ZStack {
                if showGameOverView {
                    // Show Game Over View when the game ends
                    GameOverView(
                        finalScore: score,
                        highestScore: highestScore,
                        onReplay: {
                            startNewGame() // Restart the game
                            showGameOverView = false // Hide GameOverView
                        },
                        onHome: {
                            // Add navigation to home logic here
                            print("Navigate back to home")
                        }
                    )
                    .transition(.opacity) // Smooth fade-in transition
                } else {
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
                                    }
                                )
                            
                            if let hoverShape = hoverShape, let hoverPosition = hoverPosition {
                                hoverIndicator(for: hoverShape, at: hoverPosition)
                            }
                        }
                        
                        // Blocks to Place
                        HStack(alignment: .center, spacing: 60) {
                            ForEach(blocks) { block in
                                if !block.isPlaced {
                                    ResizableBlockView(
                                        block: block,
                                        initialSize: blockCellSize * 0.7, // Smaller default size
                                        expandedSize: gridCellSize,      // Grows to match grid size when dragged
                                        onHover: { shape, globalPosition in
                                            hoverShape = shape
                                            hoverPosition = globalPosition
                                        },
                                        onDrop: { shape, finalGlobal in
                                            let success = placeBlockIfValid(shape, dropLocation: finalGlobal)
                                            if success {
                                                blocks.indices.forEach { index in
                                                    if blocks[index].id == block.id {
                                                        blocks[index].isPlaced = true
                                                        score += 10  // Increment score
                                                        blockPopupText = "+10"
                                                        blockPopupPosition = finalGlobal  // Set popup position
                                                        showBlockPopup = true
                                                    }
                                                }
                                                checkAllBlocksPlaced()
                                                clearFullRowsAndColumns(finalGlobal)
                                                checkGameOver()
                                            }
                                            hoverShape = nil
                                            hoverPosition = nil
                                            return success
                                        }
                                    )
                                    .frame(width: gridCellSize, height: gridCellSize) // Reserve space for expanded size
                                    .transition(.scale(scale: 0.0, anchor: .center).combined(with: .opacity)) // Scale + fade effect
                                }
                            }
                        }
                        .frame(maxHeight: gridCellSize) // Fix the height of the HStack to match block size
                        .padding(.horizontal, 0)
                        .padding(.top, 30)
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.5)) {
                                blocks = Self.randomThreeBlocks() // Animate new blocks when they spawn
                            }
                        }
                    }
                    .padding()
                    
                    // Display Block Placement Popup
                    if showBlockPopup {
                        popupView(text: blockPopupText, position: blockPopupPosition, color: Color.green)
                    }
                    
                    // Display Clear Rows/Columns Popup
                    if showClearPopup {
                        popupView(text: clearPopupText, position: clearPopupPosition, color: Color.blue)
                    }
                }
            }
            .onChange(of: gameOver) { isGameOver in
                if isGameOver {
                    // Delay showing the GameOverView for smooth state update
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            showGameOverView = true
                        }
                    }
                }
            }
//            .id(gameID)
        }
        
        
        
        private func checkGameOver() {
            for block in blocks where !block.isPlaced {
                if !canPlaceBlockAnywhere(block.shape) {
                    gameOver = true
                    highestScore = max(highestScore, score) // Update high score
                }
            }
        }
        
        
        private func startNewGame() {
            model = BlockGameModel()
//            model.reset()
            score = 0
            blocks = Self.randomThreeBlocks()
            gameOver = false
        }
        
        
        
        private func popupView(text: String, position: CGPoint, color: Color) -> some View {
            Text(text)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 12).fill(color).shadow(radius: 4))
                .position(position)
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if text == blockPopupText {
                            showBlockPopup = false
                        } else {
                            showClearPopup = false
                        }
                    }
                }
        }
        
        private var gridView: some View {
            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { col in
                            ZStack {
                                // Flat grid background
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2)) // Flat neutral color for the grid
                                    .frame(width: gridCellSize, height: gridCellSize)
                                    .border(Color.gray.opacity(0.5), width: 1) // Thin grid border
                                
                                if let color = model.grid[row][col] {
                                    // 3D Block
                                    ZStack {
                                        // Main block with gradient and shadow
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [color.opacity(0.9), color.opacity(0.6)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(8)
                                            .shadow(color: .black.opacity(0.4), radius: 6, x: 4, y: 4) // Deep shadow for 3D depth
                                            .shadow(color: .white.opacity(0.2), radius: 2, x: -2, y: -2) // Subtle light highlight
                                        
                                        // Glassy reflection effect on top
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.white.opacity(0.3), .clear]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .cornerRadius(8)
                                            .padding(4) // Inner glass effect
                                            .opacity(0.8)
                                    }
                                    .frame(width: gridCellSize, height: gridCellSize)
                                }
                            }
                        }
                    }
                }
            }
            .padding(4) // Add some spacing around the grid
            .background(
                Rectangle()
                    .fill(Color.black.opacity(0.05)) // Simple flat background for the grid
            )
        }
        
        
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
        
        private func isShapePlacementValid(_ shape: [[Int]], atRow row: Int, col: Int) -> Bool {
            for r in 0..<shape.count {
                for c in 0..<shape[r].count {
                    let rr = row + r
                    let cc = col + c
                    if shape[r][c] == 1 && (rr < 0 || rr >= 8 || cc < 0 || cc >= 8 || model.grid[rr][cc] != nil) {
                        return false
                    }
                }
            }
            return true
        }
        
        private func clearFullRowsAndColumns(_ position: CGPoint) {
            var clearedRows = Set<Int>()
            var clearedCols = Set<Int>()
            
            // Identify full rows and columns
            for row in 0..<8 {
                if model.grid[row].allSatisfy({ $0 != nil }) {
                    clearedRows.insert(row)
                }
            }
            for col in 0..<8 {
                if model.grid.map({ $0[col] }).allSatisfy({ $0 != nil }) {
                    clearedCols.insert(col)
                }
            }
            
            let totalClears = clearedRows.count + clearedCols.count
            if totalClears > 0 {
                let points = totalClears * 100
                score += points
                clearPopupText = "+\(points)"
                
                // Calculate popup position (centered in the cleared area)
                if let lastRow = clearedRows.max() {
                    let yPosition = gridRect.minY + CGFloat(lastRow) * gridCellSize + gridCellSize / 2
                    clearPopupPosition = CGPoint(
                        x: min(gridRect.midX, UIScreen.main.bounds.width - 50), // Ensure it doesn't go off the screen
                        y: min(yPosition, UIScreen.main.bounds.height - 50)
                    )
                } else if let lastCol = clearedCols.max() {
                    let xPosition = gridRect.minX + CGFloat(lastCol) * gridCellSize + gridCellSize / 2
                    clearPopupPosition = CGPoint(
                        x: min(xPosition, UIScreen.main.bounds.width - 50),
                        y: min(gridRect.midY, UIScreen.main.bounds.height - 50)
                    )
                }
                
                showClearPopup = true
                
                // Trigger animations for cleared rows/columns
                withAnimation(.easeInOut(duration: 0.5)) {
                    clearedRows.forEach { row in
                        for col in 0..<8 {
                            model.grid[row][col] = nil
                        }
                    }
                    clearedCols.forEach { col in
                        for row in 0..<8 {
                            model.grid[row][col] = nil
                        }
                    }
                }
                
                // Reset cleared rows/columns after the animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    clearedRows.forEach { row in
                        for col in 0..<8 {
                            model.grid[row][col] = nil
                        }
                    }
                    clearedCols.forEach { col in
                        for row in 0..<8 {
                            model.grid[row][col] = nil
                        }
                    }
                }
            }
        }
        
        
        
        private func placeBlockIfValid(_ shape: [[Int]], dropLocation: CGPoint) -> Bool {
            let localX = dropLocation.x - gridRect.minX
            let localY = dropLocation.y - gridRect.minY
            let col = Int((localX / gridCellSize).rounded(.down))
            let row = Int((localY / gridCellSize).rounded(.down))
            
            if isShapePlacementValid(shape, atRow: row, col: col) {
                for r in 0..<shape.count {
                    for c in 0..<shape[r].count {
                        if shape[r][c] == 1 {
                            model.grid[row + r][col + c] = blocks.first { $0.shape == shape }?.color
                        }
                    }
                }
                //            score += 10  // Add 10 points for each block placed
                blockPopupText = "+10"
                showBlockPopup = true
                return true
            }
            return false
        }
        
        private func checkAllBlocksPlaced() {
            if blocks.allSatisfy({ $0.isPlaced }) {
                withAnimation(.easeOut(duration: 0.5)) { // Add smooth animation
                    blocks = Self.randomThreeBlocks()
                }
            }
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
        
        static func randomThreeBlocks() -> [BlockState] {
            let shapes = [
                [[1, 1], [1, 1]],
                [[1, 1], [1, 0]],
                [[1, 1, 1]],
                [[1, 1, 1], [0, 1, 0]],
                [[1, 0], [1, 0], [1, 1]],
                [[0, 1, 0], [1, 1, 1]],
                [[1, 1, 1], [1, 1, 1], [1, 1, 1]]
            ]
            let colors: [Color] = [.red, .blue, .green, .orange, .purple, .yellow, .pink]
            return (0..<3).compactMap { _ in
                guard let shape = shapes.randomElement(), let color = colors.randomElement() else { return nil }
                return BlockState(shape: shape, color: color)
            }
        }
        
        struct ResizableBlockView: View {
            let block: BlockState
            let initialSize: CGFloat
            let expandedSize: CGFloat
            let onHover: (_ shape: [[Int]], _ globalPosition: CGPoint) -> Void
            let onDrop: (_ shape: [[Int]], _ globalPosition: CGPoint) -> Bool
            
            @State private var isDragging = false
            
            var body: some View {
                SingleBlockContainer(
                    block: block,
                    cellSize: isDragging ? expandedSize : initialSize, // Adjust size dynamically for rendering
                    highlightSize: initialSize, // Keep the highlight calculation consistent
                    onHover: onHover,
                    onDrop: { shape, globalPosition in
                        let success = onDrop(shape, globalPosition)
                        if success {
                            isDragging = false // Reset dragging state
                        }
                        return success
                    },
                    onDragStart: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            isDragging = true // Trigger resizing
                        }
                    },
                    onDragEnd: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            isDragging = false // Reset size on drag end
                        }
                    }
                )
            }
        }
    }
//}

// Preview provider for SwiftUI Canvas
//#Preview  {
//    GameView(gameID: UUID())
//}
