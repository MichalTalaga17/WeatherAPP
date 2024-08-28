import SwiftUI

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
    @State private var moveCloud = false
    
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.white.opacity(0.5))
                .frame(width: 250, height: 100)
                .blur(radius: 50)
                .offset(x: moveCloud ? 50 : -50, y: 0)
            Ellipse()
                .fill(Color.white.opacity(0.4))
                .frame(width: 200, height: 80)
                .blur(radius: 40)
                .offset(x: moveCloud ? 90 : 10, y: -20)
            Ellipse()
                .fill(Color.white.opacity(0.3))
                .frame(width: 150, height: 60)
                .blur(radius: 30)
                .offset(x: moveCloud ? -10 : -70, y: 10)
            Ellipse()
                .fill(Color.white.opacity(0.6))
                .frame(width: 160, height: 60)
                .blur(radius: 30)
                .offset(x: moveCloud ? 40 : 0, y: 30)
        }
        .opacity(0.85)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                moveCloud = true
            }
        }
    }
}

struct DaySkyView: View {
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

            Cloud()
                .offset(x: -150, y: -300)
            Cloud()
                .offset(x: 180, y: -330)
            Cloud()
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

#Preview {
    DaySkyView()
}
