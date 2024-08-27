import SwiftUI

// MARK: - MoonView
struct MoonView: View {
    var body: some View {
        ZStack {
            // Moon Base
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.9),
                            Color.white.opacity(0.4)
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: 120
                    )
                )
                .frame(width: 200, height: 200)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 10, y: 10)
            
            // Craters
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        Circle()
                            .fill(Color.gray.opacity(0.6))
                            .frame(width: 40, height: 40)
                            .offset(x: -10, y: -30)
                        
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 25, height: 25)
                            .offset(x: -60, y: 0)
                        
                        Circle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 15, height: 15)
                            .offset(x: -90, y: -40)
                    }
                }
            }
            
            // Moon Texture (Subtle)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.2),
                            Color.black.opacity(0.5)
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .blendMode(.overlay)
            
            // Moon Glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.1)
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 150
                    )
                )
                .frame(width: 200, height: 200)
                .blendMode(.softLight)
        }
    }
}

// MARK: - NightSkyView
struct NightSkyView: View {
    @StateObject private var starFieldAnimator = StarFieldAnimator(starCount: 200)
    @State private var animationTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.05, green: 0.05, blue: 0.2), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Moon
            MoonView()
                .offset(x: -100, y: -250)
            
            // Stars
            ForEach(starFieldAnimator.stars) { star in
                let blurAmount = min(1, 1 * star.position.y)
                Star(origin: star.position, size: star.size, brightness: star.brightness)
                    .fill(Color.white.opacity(star.brightness))
                    .blur(radius: blurAmount)
                    .animation(.easeInOut(duration: Double.random(in: 1.5...2.5)).repeatForever(autoreverses: true), value: star.size)
            }

            // Clouds
            Cloud()
                .offset(x: -100, y: -50)
                .blur(radius: 20)
                .animation(.linear(duration: 20).repeatForever(autoreverses: true), value: UUID())
            Cloud()
                .offset(x: 150, y: -150)
                .blur(radius: 30)
                .animation(.linear(duration: 25).repeatForever(autoreverses: true), value: UUID())

            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.clear, location: 0.0),
                    .init(color: Color.black.opacity(0.3), location: 0.7),
                    .init(color: Color.black.opacity(0.7), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.plusLighter)
            .ignoresSafeArea()
        }
        .onAppear {
            animationTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
        }
        .onReceive(animationTimer) { _ in
            starFieldAnimator.animate()
        }
        .onDisappear {
            animationTimer.upstream.connect().cancel()
        }
    }
}

// MARK: - Preview
#Preview {
    NightSkyView()
}
