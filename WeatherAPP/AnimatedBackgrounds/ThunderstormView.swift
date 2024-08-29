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
                .fill(Color.white.opacity(0.8))
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

private struct Lightning: View {
    @State private var showFlash = false
    @State private var currentFlashInterval: TimeInterval = Double.random(in: 5...12)
    let flashDuration: TimeInterval = 0.1
    
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(showFlash ? 0.8 : 0))
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: currentFlashInterval, repeats: true) { _ in
                    withAnimation(Animation.easeInOut(duration: flashDuration)) {
                        showFlash = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + flashDuration) {
                        withAnimation {
                            showFlash = false
                        }
                    }
                    currentFlashInterval = Double.random(in: 5...12)
                }
            }
    }
}

struct ThunderstormView: View {
    let isDaytime: Bool
    let cloudiness: Double
    let precipitationType: PrecipitationType
    let precipitationIntensity: Int

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: isDaytime
                    ? [Color.blue.opacity(0.5), Color.gray.opacity(0.8)]
                    : [Color.gray.opacity(0.9), Color.black.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            PrecipitationView(type: precipitationType, intensity: precipitationIntensity)
                .offset(y: 0)
            
            Lightning()
        }
    }
}

#Preview {
    ThunderstormView(
        isDaytime: true,
        cloudiness: 0,
        precipitationType: .rain,
        precipitationIntensity: 100
    )
}
