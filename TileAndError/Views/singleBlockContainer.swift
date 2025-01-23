//
//  singleBlockContainer.swift
//  TileAndError
//
//  Created by Abdullah Khan on 1/22/25.
//

import SwiftUI

// MARK: - SingleBlockContainer
struct SingleBlockContainer: View {
    let block: BlockState
    let cellSize: CGFloat
    let onHover: (_ shape: [[Int]], _ position: CGPoint) -> Void
    let onDrop: (_ shape: [[Int]], _ finalGlobal: CGPoint) -> Bool

    @State private var offset: CGSize = .zero
    @State private var dragStart: CGPoint = .zero
    @State private var isDragging = false

    var body: some View {
        BlockView(block: block.shape, cellSize: cellSize, color: block.color)
            .scaleEffect(isDragging ? 1.1 : 1.0)
            .opacity(isDragging ? 0.8 : 1.0)
            .offset(offset)
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        if offset == .zero {
                            dragStart = value.startLocation
                        }
                        offset = value.translation
                        onHover(block.shape, value.location)
                        isDragging = true
                    }
                    .onEnded { value in
                        let finalGlobal = CGPoint(
                            x: dragStart.x + value.translation.width,
                            y: dragStart.y + value.translation.height
                        )
                        let placed = onDrop(block.shape, finalGlobal)
                        if !placed {
                            offset = .zero
                        }
                        isDragging = false
                    }
            )
    }
}
