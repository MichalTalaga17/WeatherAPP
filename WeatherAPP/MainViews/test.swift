import SwiftUI
import Combine

// StarFieldAnimator
class StarFieldAnimator: ObservableObject {
    class StarModel: Identifiable {
        var position: CGPoint
        var size: CGFloat
        var brightness: Double
        let id = UUID().uuidString

        internal init(position: CGPoint, size: CGFloat, brightness: Double) {
            self.position = position
            self.size = size
            self.brightness = brightness
        }
    }

    @Published private(set) var stars: [StarModel] = []

    init(starCount: Int) {
        for _ in 0..<starCount {
            let star = StarModel(
                position: .init(x: CGFloat.random(in: 0...1), y: CGFloat.random(in: 0...1)),
                size: CGFloat.random(in: 1...3),
                brightness: Double.random(in: 0.5...1.0)
            )
            stars.append(star)
        }
    }

    func animate() {
        objectWillChange.send()
        for star in stars {
            star.size = CGFloat.random(in: 1...3)
            star.brightness = Double.random(in: 0.5...1.0)
        }
    }
}
private struct Star: Shape {
    var origin: CGPoint
    var size: CGFloat
    var brightness: Double

    func path(in rect: CGRect) -> Path {
        let adjustedX = rect.width * origin.x
        let adjustedY = rect.height * origin.y
        let starRect = CGRect(x: adjustedX - size / 2, y: adjustedY - size / 2, width: size, height: size)
        return Path(ellipseIn: starRect)
    }

    var animatableData: AnimatablePair<CGPoint.AnimatableData, AnimatablePair<CGFloat, Double>> {
        get {
            AnimatablePair(origin.animatableData, AnimatablePair(size, brightness))
        }
        set {
            origin.animatableData = newValue.first
            size = newValue.second.first
            brightness = newValue.second.second
        }
    }
}

// Cloud Shape
private struct Cloud: View {
    var body: some View {
        Ellipse()
            .fill(Color.white.opacity(0.1))
            .blur(radius: 30)
            .frame(width: 200, height: 100)
            .opacity(0.5)
    }
}

// NightSkyView
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

// Preview
#Preview {
    NightSkyView()
}

