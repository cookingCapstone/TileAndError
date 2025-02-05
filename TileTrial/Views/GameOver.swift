//
//  GameOver.swift
//  TileAndError
//
//  Created by Abdullah Khan on 1/27/25.

import SwiftUI

struct GameOverView: View {
    var finalScore: Int
    var highestScore: Int
    var onReplay: () -> Void
    var onHome: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var showTrophy = false
    @State private var trophyScale: CGFloat = 0.1

    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Text("Game Over")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(spacing: 10) {
                    Text("Your Score: \(finalScore)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)

                    Text("Highest Score: \(highestScore)")
                        .font(.title3)
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.7))
                }

                // 🏆 Trophy Animation (Only if New High Score)
                if finalScore >= highestScore {
                    Image(systemName: "trophy.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.yellow)
                        .scaleEffect(trophyScale)
                        .opacity(showTrophy ? 1 : 0)
                        .onAppear {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0.5)) {
                                showTrophy = true
                                trophyScale = 1.0
                            }
                        }
                }

                HStack(spacing: 20) {
                    Button(action: {
                        onReplay()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Replay")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 140)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }

                    Button(action: {
                        onHome()
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 140)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if finalScore > highestScore {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showTrophy = true
                }
            }
        }
    }
}

struct GameOverView_Previews: PreviewProvider {
    static var previews: some View {
        GameOverView(
            finalScore: 5000,  // Example score to trigger trophy
            highestScore: 5000,
            onReplay: {
                print("Replay tapped")
            },
            onHome: {
                print("Home tapped")
            }
        )
    }
}
