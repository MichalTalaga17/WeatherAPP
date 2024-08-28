import SwiftUI

// Enum for Precipitation Type
enum PrecipitationType {
    case rain, snow, hail
}

// View for a Single Precipitation Particle
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
// View for Precipitation Effect
private struct PrecipitationView: View {
    let type: PrecipitationType
    let intensity: Int // Number of particles
    
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

// Main View for Rainy Day Sky with Precipitation Effects
struct RainyDaySkyView: View {
    let isDaytime: Bool
    let cloudiness: Double // 0.0 (clear) to 1.0 (fully overcast)
    let precipitationType: PrecipitationType
    let precipitationIntensity: Int // Number of precipitation particles
    
    var body: some View {
        ZStack {
            // Background gradient simulating sky based on day/night and cloudiness
            LinearGradient(
                gradient: Gradient(colors: [
                    isDaytime ? Color.blue.opacity(1.0 - cloudiness) : Color.black.opacity(1.0 - cloudiness), // Sky color
                    Color.gray.opacity(cloudiness), // Cloud layer
                    Color.gray.opacity(cloudiness + 0.2) // Darker cloud base
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
        isDaytime: false,
        cloudiness: 0,
        precipitationType: .hail,
        precipitationIntensity: 100
    )
}
