//import SwiftUI
//
//struct HomePage: View {
//    
//    @State private var gameID = UUID()
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // Background gradient for a modern block puzzle feel
//                LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.8)]),
//                               startPoint: .top, endPoint: .bottom)
//                    .edgesIgnoringSafeArea(.all)
//                
//                VStack(spacing: 30) {
//                    // Game Title with Pixelated Font
//                    Text("Tile and Error")
//                        .font(.system(size: 40, weight: .bold, design: .monospaced))
//                        .foregroundColor(.white)
//                        .shadow(color: .blue, radius: 5)
//                    
//                    // Start Game Button
//                    NavigationLink(destination: GameLogic().navigationBarBackButtonHidden(true)) {
//                        buttonStyle(text: "Regular Mode", color: .blue)
//                    }
//                    
//                    // Timed Mode Button
//                    NavigationLink(destination: TimedGameLogic().navigationBarBackButtonHidden(true)) {
//                        buttonStyle(text: "Timed Mode", color: .red)
//                    }
//                    
//                    // Chaos Mode Button
//                    NavigationLink(destination: ChaosMode().navigationBarBackButtonHidden(true)) {
//                        buttonStyle(text: "Chaos Mode", color: .purple)
//                    }
//
//                    // Instructions Button
//                    NavigationLink(destination: InstructionsView()) {
//                        buttonStyle(text: "Instructions", color: .green)
//                    }
//                }
//                .padding()
//            }
//        }
//    }
//    
//    // Custom button style for neon glow effect
//    @ViewBuilder
//    private func buttonStyle(text: String, color: Color) -> some View {
//        Text(text)
//            .font(.title2)
//            .fontWeight(.bold)
//            .foregroundColor(.white)
//            .padding()
//            .frame(maxWidth: 250)
//            .background(color)
//            .cornerRadius(12)
//            .shadow(color: color.opacity(0.8), radius: 10, x: 0, y: 5)
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
//            )
//    }
//}
//
//#Preview {
//    HomePage()
//}


import SwiftUI

struct HomePage: View {
    
    @State private var gameID = UUID()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient for a modern block puzzle feel
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.8)]),
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                // Faster Generating Smaller Outlined Squares (Spread Out)
                ContinuousSmallOutlinedSquares()

                VStack(spacing: 30) {
                    // Game Title with Pixelated Font
                    Text("Tile & Error")
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: .blue, radius: 5)
                    
                    // Start Game Button
                    NavigationLink(destination: GameLogic().navigationBarBackButtonHidden(true)) {
                        buttonStyle(text: "Regular Mode", color: .blue)
                    }
                    
                    // Timed Mode Button
                    NavigationLink(destination: TimedGameLogic().navigationBarBackButtonHidden(true)) {
                        buttonStyle(text: "Timed Mode", color: .red)
                    }
                    
                    // Chaos Mode Button
                    NavigationLink(destination: ChaosMode().navigationBarBackButtonHidden(true)) {
                        buttonStyle(text: "Chaos Mode", color: .purple)
                    }

                    // Instructions Button
                    NavigationLink(destination: InstructionsView()) {
                        buttonStyle(text: "Instructions", color: .green)
                    }
                }
                .padding()
            }
        }
    }
    
    // Custom button style for neon glow effect
    @ViewBuilder
    private func buttonStyle(text: String, color: Color) -> some View {
        Text(text)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: 250)
            .background(color)
            .cornerRadius(12)
            .shadow(color: color.opacity(0.8), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
            )
    }
}

// MARK: - Continuous Small Outlined Squares (Fully Spread)
struct ContinuousSmallOutlinedSquares: View {
    @State private var squares: [SquareModel] = []
    
    var body: some View {
        ZStack {
            ForEach(squares) { square in
                squareView(for: square)
                    .position(square.position)
                    .frame(width: square.size, height: square.size)
                    .opacity(square.opacity)
                    .animation(.easeInOut(duration: square.animationDuration).repeatForever(autoreverses: true), value: square.position)
            }
        }
        .onAppear {
            print("🚀 Background Small Outlined Squares Started")
            startGeneratingSquares()
        }
    }
    
    // Function to continuously generate squares (Faster speed: 0.5s)
    private func startGeneratingSquares() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            let newSquare = createRandomSquare()
            withAnimation(.easeInOut(duration: newSquare.animationDuration)) {
                squares.append(newSquare)
            }
            
            // Debugging
            print("✨ New Small Square Added at X:\(newSquare.position.x), Y:\(newSquare.position.y), Total: \(squares.count)")
            
            // Remove old squares after 8 seconds to prevent clutter
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                if !squares.isEmpty {
                    squares.removeFirst()
                    print("🗑 Small Square Removed, Remaining: \(squares.count)")
                }
            }
        }
    }
    
    // Function to create a random small outlined square (Fully Spread)
    private func createRandomSquare() -> SquareModel {
        let screenSize = UIScreen.main.bounds

        let randomSize = CGFloat.random(in: 20...50) // Smaller squares
        let randomX = CGFloat.random(in: 0...screenSize.width) // Fully spread from left to right
        let randomY = CGFloat.random(in: 0...screenSize.height)
        let randomOpacity = Double.random(in: 0.4...0.8) // Softer visibility
        let randomAnimationDuration = Double.random(in: 4...8) // Smooth movement

        return SquareModel(
            id: UUID(),
            size: randomSize,
            position: CGPoint(x: randomX, y: randomY), // Fully scattered
            opacity: randomOpacity,
            animationDuration: randomAnimationDuration
        )
    }
    
    // View builder for outlined squares
    @ViewBuilder
    private func squareView(for square: SquareModel) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .stroke(Color.white, lineWidth: 2) // White outline
            .background(Color.clear) // No fill
            .shadow(color: Color.white.opacity(0.2), radius: 3) // Subtle glow effect
    }
}

// MARK: - Square Model
struct SquareModel: Identifiable {
    let id: UUID
    let size: CGFloat
    var position: CGPoint
    var opacity: Double
    var animationDuration: Double
}

#Preview {
    HomePage()
}
