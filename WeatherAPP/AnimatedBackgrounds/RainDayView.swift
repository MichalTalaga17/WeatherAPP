import SwiftUI

private struct PrecipitationParticle: View {
    @State private var dropFall = false
    let type: PrecipitationType

    var body: some View {
        let size: CGSize
        let blurRadius: CGFloat
        
        switch type {
        case .rain:
            size = CGSize(width: 2, height: 50)
            blurRadius = 1
        case .snow:
            size = CGSize(width: 5, height: 5)
            blurRadius = 2
        case .hail:
            size = CGSize(width: 10, height: 10)
            blurRadius = 1
        }

        return Group {
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: size.width, height: size.height)
                .blur(radius: blurRadius)
                .offset(y: dropFall ? 800 : -800)
                .onAppear {
                    withAnimation(Animation.linear(duration: Double.random(in: 0.8...1.5)).repeatForever(autoreverses: false)) {
                        dropFall = true
                    }
                }
        }
    }
}

private struct PrecipitationView: View {
    let type: PrecipitationType
    let intensity: Int
    
    var body: some View {
        ZStack {
            ForEach(0..<intensity, id: \.self) { _ in
                PrecipitationParticle(type: type)
                    .offset(x: CGFloat.random(in: -200...200))
                    .animation(Animation.linear(duration: Double.random(in: 0.8...1.5)).repeatForever(autoreverses: false), value: UUID())
            }
        }
    }
}

struct RainyDaySkyView: View {
    let isDaytime: Bool
    let cloudiness: Double
    let precipitationType: PrecipitationType
    let precipitationIntensity: Int
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    isDaytime ? Color.blue.opacity(1.0 - cloudiness) : Color.black.opacity(1.0 - cloudiness/2),
                    Color.gray.opacity(cloudiness + 0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Precipitation Effect
            PrecipitationView(type: precipitationType, intensity: precipitationIntensity)
                .offset(y: 0)
        }
    }
}

// Preview
#Preview {
    RainyDaySkyView(
        isDaytime: true,
        cloudiness: 0.8,
        precipitationType: .snow,
        precipitationIntensity: 300
    )
}
