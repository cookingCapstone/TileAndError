//
//  Item.swift
//  TileAndError
//
//  Created by Abdullah Khan on 1/9/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
