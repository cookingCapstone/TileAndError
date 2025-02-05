//
//  singleBlockContainer.swift
//  TileAndError
//
//  Created by Abdullah Khan on 1/22/25.
//
//
import SwiftUI

struct SingleBlockContainer: View {
    let block: BlockState
    let cellSize: CGFloat // Dynamic size for rendering
    let highlightSize: CGFloat // Fixed size for hover highlight calculation
    let onHover: (_ shape: [[Int]], _ position: CGPoint) -> Void
    let onDrop: (_ shape: [[Int]], _ finalGlobal: CGPoint) -> Bool
    let onDragStart: () -> Void // Callback for when dragging starts
    let onDragEnd: () -> Void   // Callback for when dragging ends

    @State private var offset: CGSize = .zero
    @State private var dragStart: CGPoint = .zero
    @State private var isDragging = false

    var body: some View {
        BlockView(block: block.shape, cellSize: cellSize, color: block.color)
            .scaleEffect(isDragging ? 1.1 : 1.0) // Slightly enlarge when dragging
            .opacity(isDragging ? 0.8 : 1.0)     // Make transparent when dragging
            .offset(offset)                     // Apply drag offset
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        if !isDragging {
                            dragStart = value.startLocation
                            isDragging = true
                            onDragStart() // Notify parent that dragging has started
                        }
                        offset = value.translation
                        let adjustedPosition = CGPoint(
                            x: value.startLocation.x + value.translation.width - highlightSize * CGFloat(block.shape[0].count) / 2,
                            y: value.startLocation.y + value.translation.height - highlightSize * CGFloat(block.shape.count) / 2
                        )
                        onHover(block.shape, adjustedPosition) // Use `highlightSize` for hover alignment
                    }
                    .onEnded { value in
                        let finalGlobal = CGPoint(
                            x: dragStart.x + value.translation.width - highlightSize * CGFloat(block.shape[0].count) / 2,
                            y: dragStart.y + value.translation.height - highlightSize * CGFloat(block.shape.count) / 2
                        )
                        let placed = onDrop(block.shape, finalGlobal) // Try to place block
                        if !placed {
                            offset = .zero // Reset offset if not placed
                        }
                        isDragging = false // Reset dragging state
                        onDragEnd() // Notify parent that dragging has ended
                    }
            )
    }
}
