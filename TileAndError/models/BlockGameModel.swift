//
//  BlockGameModel.swift
//  TileAndError
//
//  Created by Abdullah Khan on 1/22/25.
//

//
//  BlockGameModel.swift
//  Represents the game grid state.
//
//  This file contains the `BlockGameModel` struct, which defines the 8x8 game grid. It manages
//  the colors of grid cells and tracks the overall grid state. This is essential for gameplay
//  mechanics like block placement and row/column clearing.
//
import SwiftUI

struct BlockGameModel {
    var grid: [[Color?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
}
