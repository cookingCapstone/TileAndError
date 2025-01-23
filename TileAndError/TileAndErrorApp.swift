//
//  TileAndErrorApp.swift
//  TileAndError
//
//  Created by Abdullah Khan on 1/9/25.
//


//
//  TileAndErrorApp.swift
//  Entry point of the app.
//
//  This file initializes the app and sets up the main window group to display the `GameView`.
//  It ensures the app launches correctly and shows the core gameplay screen.
//
import SwiftUI

@main
struct TileAndErrorApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .ignoresSafeArea()
        }
    }
}
