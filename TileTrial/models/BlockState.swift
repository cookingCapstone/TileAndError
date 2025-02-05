//
//  BlockState.swift
//  TileAndError
//
//  Created by Abdullah Khan on 1/22/25.
//

//
//  BlockState.swift
//  Defines the structure for individual blocks.
//
//  This file contains the `BlockState` struct, which represents the properties of a block,
//  including its shape, color, and placement status. It is essential for managing block
//  behaviors and attributes during the game.
//
import SwiftUI

struct BlockState: Identifiable {
    let id = UUID()
    var shape: [[Int]]   // 2D array of 1/0
    var isPlaced = false
    var color: Color     // Color of the block
}
