//
//  ChaosMode.swift
//  TileAndError
//
//  Created by Abdullah Khan on 1/28/25.
//

////
import SwiftUI

struct ChaosMode: View {
    @StateObject private var model: BlockGameModel = BlockGameModel()
    @State private var blocks: [BlockState] = Self.randomThreeBlocks()
    @State private var gridRect: CGRect = .zero
    @State private var chaosScore: Int = 0
    @AppStorage("chaosHighestScore") private var chaosHighestScore = 0
    @State private var gameOver: Bool = false
    @State private var showGameOverView: Bool = false
    @State private var hoverShape: [[Int]]? = nil
    @State private var hoverPosition: CGPoint? = nil
    
    @State private var blockPopupText: String = ""
    @State private var showBlockPopup: Bool = false
    @State private var blockPopupPosition: CGPoint = .zero
    
    @State private var clearPopupText: String = ""
    @State private var showClearPopup: Bool = false
    @State private var clearPopupPosition: CGPoint = .zero
    @State private var navigateToHome: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @State private var showChaosInstructions: Bool = false
    
    @AppStorage("HasSeenChosInstructions") private var hasSeenChaosInstructions = false
    @State private var borderProgress: CGFloat = 0.0
    @State private var showBorder = true
    @State private var borderOpacity: CGFloat = 1.0

    
    
    let gridCellSize: CGFloat = 45
    let blockCellSize: CGFloat = 40
    
    // Predefined blocks for Chaos Mode
    let chaosBlocks: [[[Int]]] = [
        [[1, 1], [1, 1]],
        [[1, 1], [1, 0]],
        [[1, 1, 1]],
        [[1, 1, 1], [0, 1, 0]],
        [[1, 0], [1, 0], [1, 1]],
        [[0, 1, 0], [1, 1, 1]],
        [[1, 1, 1], [1, 1, 1], [1, 1, 1]]
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // Dynamic background gradient based on light or dark mode
                    let backgroundColors = colorScheme == .dark
                                 ? [Color.black, Color.blue.opacity(0.8)]
                                 : [Color.white, Color.blue.opacity(0.4)]
                             
                             LinearGradient(gradient: Gradient(colors: backgroundColors),
                                            startPoint: .top, endPoint: .bottom)
                                 .edgesIgnoringSafeArea(.all)
                
                if showGameOverView {
                    GameOverView(
                        finalScore: chaosScore,
                        highestScore: chaosHighestScore,
                        onReplay: {
                            startNewGame()
                            showGameOverView = false
                        },
                        onHome: {
                            navigateToHome = true
                        }
                    )
                    .transition(.opacity)
                    
                } else {
                    VStack(spacing: 20) {
//                        NavigationLink(destination: HomePage().navigationBarBackButtonHidden(true)) {
//                            Image(systemName: "house.fill")
//                                .font(.title)
//                                .foregroundColor(.blue)
//                                .padding()
//                        }
////
//                    
//                    .frame(maxWidth: .infinity, alignment: .leading) // Pushes button to top-left
//                    .padding(.top, 10)
                        
                        HStack {
                            Text("High Score: \(chaosHighestScore)")
                                .font(.title2)
                            Spacer()
                            Text("Score: \(chaosScore)")
                                .font(.title2)
                        }
                        .padding(.horizontal)
                        
                        ZStack(alignment: .topLeading) {
                            gridView
                                .frame(width: gridCellSize * 8, height: gridCellSize * 8)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .onAppear {
                                                gridRect = geo.frame(in: .global)
                                                print("Grid Rect Updated: \(gridRect)")
                                            }
                                            .onChange(of: geo.frame(in: .global)) { newFrame in
                                                gridRect = newFrame
                                                print("Grid Rect Updated (onChange): \(gridRect)")
                                            }
                                    }
                                )
                            if let hoverShape = hoverShape, let hoverPosition = hoverPosition {
                                hoverIndicator(for: hoverShape, at: hoverPosition)
                            }
                        }
                        
                        HStack(alignment: .center, spacing: 60) {
                            ForEach(blocks) { block in
                                if !block.isPlaced {
                                    ResizableBlockView(
                                        block: block,
                                        initialSize: blockCellSize * 0.7,
                                        expandedSize: gridCellSize,
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
                                                        chaosScore += 10
                                                        blockPopupText = "+10"
                                                        blockPopupPosition = finalGlobal
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
                                    .frame(width: gridCellSize, height: gridCellSize)
                                    .transition(.scale(scale: 0.0, anchor: .center).combined(with: .opacity))
                                }
                            }
                        }
                        .frame(maxHeight: gridCellSize)
                        .padding(.horizontal, 0)
                        .padding(.top, 30)
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.5)) {
                                blocks = Self.randomThreeBlocks()
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if chaosScore == 0 && !hasSeenChaosInstructions  {
                                showChaosInstructions = true
                            }
                        }
                    }
                    
                    if showChaosInstructions {
                        InstructionsPopup(showChaosInstructions: $showChaosInstructions, hasSeenChaosInstructions: $hasSeenChaosInstructions)
                                            .transition(.opacity)
                                            .zIndex(1)
                                    }
                    
                    if showBlockPopup {
                        popupView(text: blockPopupText, position: blockPopupPosition, color: Color.green)
                    }
                    
                    if showClearPopup {
                        popupView(text: clearPopupText, position: clearPopupPosition, color: Color.blue)
                    }
                }
            }
            .onChange(of: gameOver) { isGameOver in
                if isGameOver {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            showGameOverView = true
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomePage()
                .navigationBarBackButtonHidden(true)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: HomePage().navigationBarBackButtonHidden(true)) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
            }

        }
    }
    
    private func checkGameOver() {
        // Filter out the blocks that have not yet been placed.
        let unplacedBlocks = blocks.filter { !$0.isPlaced }
        
        // End the game only if none of the unplaced blocks can be placed anywhere.
        if unplacedBlocks.allSatisfy({ !canPlaceBlockAnywhere($0.shape) }) {
            gameOver = true
            chaosHighestScore = max(chaosHighestScore, chaosScore) // Update high score
        }
    }

    private func startNewGame() {
        model.reset()
        chaosScore = 0
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
        ZStack {
            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { col in
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: gridCellSize, height: gridCellSize)
                                    .border(Color.gray.opacity(0.5), width: 1)

                                if let color = model.grid[row][col] {
                                    ZStack {
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [color.opacity(0.9), color.opacity(0.6)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(8)
                                            .shadow(color: .black.opacity(0.4), radius: 6, x: 4, y: 4)
                                            .shadow(color: .white.opacity(0.2), radius: 2, x: -2, y: -2)

                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.white.opacity(0.3), .clear]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .cornerRadius(8)
                                            .padding(4)
                                            .opacity(0.8)
                                    }
                                    .frame(width: gridCellSize, height: gridCellSize)
                                }
                            }
                        }
                    }
                }
            }
            .padding(4)
            .background(
                Rectangle()
                    .fill(Color.black.opacity(0.05))
            )
            

            if showBorder {
                RoundedRectangle(cornerRadius: 5)
                    .trim(from: 0, to: borderProgress) // Ensures smooth animated stroke
                    .stroke(Color.white.opacity(borderOpacity), lineWidth: 2) // Thinner stroke
                    .frame(width: gridCellSize * 8 + 8, height: gridCellSize * 8 + 8)
                    .animation(.easeInOut(duration: 2.5), value: borderProgress)
                    .onAppear {
                        // Start smooth animation around the grid
                        withAnimation(.easeInOut(duration: 2.5)) {
                            borderProgress = 1.0
                        }
                        
                        // Keep the border fully visible for longer before fading out
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeOut(duration: 1.5)) { // Fade out slower over 1.5 seconds
                                borderOpacity = 0.0
                            }
                        }
                        
                        // Hide the border completely only after the fade-out finishes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                            showBorder = false
                        }
                    }

            }
        }
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
    
    
    struct InstructionsPopup: View {
        @Binding var showChaosInstructions: Bool
        @Binding var hasSeenChaosInstructions: Bool  // Track if the user has seen it
        
        var body: some View {
            ZStack {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Instructions")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Place a block… but don’t get too comfortable! In Chaos Mode, blocks transform after being placed. Can you keep up with the ever-changing grid?")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(action: {
                        withAnimation {
                            showChaosInstructions = false
                            hasSeenChaosInstructions = true  // Mark instructions as seen
                        }
                    }) {
                        Text("Got it!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 120)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.6))
                .cornerRadius(20)
                .shadow(radius: 10)
                .frame(width: 300)
            }
            .transition(.opacity)
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
            chaosScore += points
            clearPopupText = "+\(points)"
            
            if let lastRow = clearedRows.max() {
                let yPosition = gridRect.minY + CGFloat(lastRow) * gridCellSize + gridCellSize / 2
                clearPopupPosition = CGPoint(
                    x: min(gridRect.midX, UIScreen.main.bounds.width - 50),
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

        var clearedExistingBlock = false
        
        // First, check if the placement is valid
        if isShapePlacementValid(shape, atRow: row, col: col) {
            let randomBlock = chaosBlocks.randomElement()!
            let randomColor = [Color.red, .blue, .green, .orange, .purple, .yellow, .pink].randomElement()!
            
            // **CLEAR existing blocks** before placing new ones
            for r in 0..<randomBlock.count {
                for c in 0..<randomBlock[r].count {
                    let gridRow = row + r
                    let gridCol = col + c
                    
                    if gridRow < 8 && gridCol < 8 {
                        if model.grid[gridRow][gridCol] != nil {
                            model.grid[gridRow][gridCol] = nil // Remove existing block
                            clearedExistingBlock = true
                        }
                    }
                }
            }

            // **Place the new block only after clearing old ones**
            for r in 0..<randomBlock.count {
                for c in 0..<randomBlock[r].count {
                    let gridRow = row + r
                    let gridCol = col + c
                    if gridRow < 8 && gridCol < 8 {
                        model.grid[gridRow][gridCol] = randomColor
                    }
                }
            }

            // **Update score & show pop-up**
            if clearedExistingBlock {
                chaosScore += 15
                clearPopupText = "+15"
                clearPopupPosition = dropLocation
                showClearPopup = true
            } else {
                chaosScore += 10
                blockPopupText = "+10"
                blockPopupPosition = dropLocation
                showBlockPopup = true
            }

            return true
        }
        return false
    }
    
    private func checkAllBlocksPlaced() {
        if blocks.allSatisfy({ $0.isPlaced }) {
            withAnimation(.easeOut(duration: 0.5)) {
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
                cellSize: isDragging ? expandedSize : initialSize,
                highlightSize: initialSize,
                onHover: onHover,
                onDrop: { shape, globalPosition in
                    let success = onDrop(shape, globalPosition)
                    if success {
                        isDragging = false
                    }
                    return success
                },
                onDragStart: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        isDragging = true
                    }
                },
                onDragEnd: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        isDragging = false
                    }
                }
            )
        }
    }
}

#Preview {
    ChaosMode()
}
