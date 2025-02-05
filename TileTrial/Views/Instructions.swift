//  InstructionsView.swift
//  TileAndError
//
//  Created by Abdullah Khan on 1/23/25.
//

import SwiftUI

struct InstructionsView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Dynamic background gradient based on light or dark mode
            let backgroundColors = colorScheme == .dark
                ? [Color.black, Color.blue.opacity(0.8)]
                : [Color.white, Color.blue.opacity(0.3)]
            
            LinearGradient(gradient: Gradient(colors: backgroundColors),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Title with matching styling
                Text("Welcome to Tile & Error!")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .shadow(color: colorScheme == .dark ? Color.blue : Color.gray, radius: 5)
                    .padding(.top, 40)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("How to play")
                            .font(.system(size: 24, weight: .semibold, design: .monospaced))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        Text("Place blocks on the grid to fill rows or columns. Completing a line clears it and earns you points.")
                            .font(.system(size: 18))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .multilineTextAlignment(.leading)
                        
                        Text("Tips:")
                            .font(.system(size: 20, weight: .semibold, design: .monospaced))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        Text("""
• Plan ahead: Check the grid before placing blocks.
• Keep it balanced: Spread your blocks evenly.
• Aim for multiples: Clear several lines at once.
• Experiment: Try different placements.
• Adapt in Chaos Mode: Adjust as blocks clear.
""")
                            .font(.system(size: 18))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Navigation Link for "Back to Home" at the bottom
                NavigationLink(destination: HomePage().navigationBarBackButtonHidden(true)) {
                    Text("Back to Home")
                        .font(.system(size: 24, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        // Toolbar item for quick navigation back to Home
    }
}



#Preview {
    NavigationView {
        InstructionsView()
    }
    .preferredColorScheme(.dark) // Test in dark mode; change to .light for light mode
}
