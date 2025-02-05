//
//  GameView.swift
//  TileAndError
//
//  Created by Abdullah Khan on 1/27/25.
//

import SwiftUI

struct GameView: View {
    @State private var navigateToHome = false // Controls navigation back to Home

    var body: some View {
        NavigationStack {
            ZStack {
                GameLogic() // Game logic remains inside
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { // Move Home Button to the top-left
                    Button(action: {
                        navigateToHome = true
                    }) {
                        Image(systemName: "house.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomePage()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    GameView()
}
