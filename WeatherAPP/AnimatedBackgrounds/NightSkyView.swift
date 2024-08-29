import SwiftUI
import Combine

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

private struct Sun: View {
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.6), Color.yellow.opacity(0.3), Color.clear]),
                        startPoint: .center,
                        endPoint: .bottom
                    ),
                    lineWidth: 50
                )
                .frame(width: 300, height: 300)
                .blur(radius: 50)
            
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.8), Color.yellow.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 150, height: 150)
                .blur(radius: 30)
                .scaleEffect(pulse ? 1.1 : 1.0)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                }
        }
    }
}

private struct Cloud: View {
    var cloudiness: Cloudiness

    var body: some View {
        let opacity: Double
        let blurRadius: CGFloat
        let offset: CGFloat
        
        switch cloudiness {
        case .clear:
            opacity = 0.0
            blurRadius = 0
            offset = 0
        case .few:
            opacity = 0.2
            blurRadius = 20
            offset = 20
        case .scattered:
            opacity = 0.5
            blurRadius = 30
            offset = 30
        case .broken:
            opacity = 0.65
            blurRadius = 35
            offset = 35
        case .overcast:
            opacity = 0.8
            blurRadius = 40
            offset = 40
        }

        return ZStack {
            Ellipse()
                .fill(Color.white.opacity(opacity))
                .blur(radius: blurRadius)
                .frame(width: 200, height: 100)
                .offset(x: offset, y: 0)
            
        }
    }
}

// DaySkyView
private struct DaySkyView: View {
    var cloudiness: Cloudiness

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.6, blue: 0.85),
                    Color(red: 0.6, green: 0.85, blue: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Sun()
                .offset(x: 0, y: -250)

            Cloud(cloudiness: cloudiness)
                .offset(x: -150, y: -300)
            Cloud(cloudiness: cloudiness)
                .offset(x: 180, y: -330)
            Cloud(cloudiness: cloudiness)
                .offset(x: 80, y: -150)

            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.clear, location: 0.0),
                    .init(color: Color.white.opacity(0.1), location: 0.6),
                    .init(color: Color.white.opacity(0.3), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.overlay)
            .ignoresSafeArea()
            
            RadialGradient(gradient: Gradient(colors: [Color.white.opacity(0.15), Color.clear]), center: .center, startRadius: 10, endRadius: 400)
                .blendMode(.plusLighter)
                .offset(x: 0, y: -250)
                .ignoresSafeArea()
        }
    }
}

private struct NightSkyView: View {
    @StateObject private var starFieldAnimator = StarFieldAnimator(starCount: 200)
    @State private var animationTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    var cloudiness: Cloudiness

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.05, green: 0.05, blue: 0.2), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ForEach(starFieldAnimator.stars) { star in
                let blurAmount = min(1, 1 * star.position.y)
                Star(origin: star.position, size: star.size, brightness: star.brightness)
                    .fill(Color.white.opacity(star.brightness))
                    .blur(radius: blurAmount)
                    .animation(.easeInOut(duration: Double.random(in: 1.5...2.5)).repeatForever(autoreverses: true), value: star.size)
            }

            Cloud(cloudiness: cloudiness)
                .offset(x: -100, y: -50)
                .blur(radius: 20)
                .animation(.linear(duration: 20).repeatForever(autoreverses: true), value: UUID())
            Cloud(cloudiness: cloudiness)
                .offset(x: 150, y: -150)
                .blur(radius: 30)
                .animation(.linear(duration: 25).repeatForever(autoreverses: true), value: UUID())

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

struct SkyView: View {
    var day: Bool
    var cloudiness: Cloudiness

    var body: some View {
        if day {
            DaySkyView(cloudiness: cloudiness)
        } else {
            NightSkyView(cloudiness: cloudiness)
        }
    }
}

#Preview {
    SkyView(day: false, cloudiness: .clear)
}
