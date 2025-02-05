import SwiftUI

struct SplashScreenView: View {
    @State private var rotationAngle: Double = 0

    var body: some View {
        ZStack {
            // 🔹 Force Background Image to Exactly Match the Launch Screen
            Image("launch")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped() // Prevents any resizing artifacts
                .ignoresSafeArea()

            // 🔹 Spinning Logo at 3/4 Screen Height
            GeometryReader { geometry in
                VStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100) // Smaller logo
                        .rotationEffect(.degrees(rotationAngle))
                        .onAppear {
                            withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                                rotationAngle = 360
                            }
                        }
                    
                    // 🔹 Added Text Below the Logo
                    Text("Just put the blocks on the grid")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.75)
            }
        }
    }
}

struct ContentView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                HomePage() // Replace with your actual main view
            }
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

