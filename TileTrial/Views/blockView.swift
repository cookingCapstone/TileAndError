//
//  blockView.swift
//  TileAndError
//
//  Created by Abdullah Khan on 1/22/25.
////
import SwiftUI
//
struct BlockView: View {
    let block: [[Int]] // 2D array representing the shape of the block
    let cellSize: CGFloat
    let color: Color

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<block.count, id: \.self) { r in
                HStack(spacing: 0) {
                    ForEach(0..<block[r].count, id: \.self) { c in
                        if block[r][c] == 1 {
                            // Render filled block cell
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [color.opacity(0.8), color]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: cellSize, height: cellSize)
                                .cornerRadius(8)
                                .shadow(color: color.opacity(0.5), radius: 4, x: 2, y: 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(color.opacity(0.9), lineWidth: 2)
                                )
                        } else {
                            // Render empty space for block padding
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
        .padding(.all, 0) // Ensure no extra spacing
    }
}


