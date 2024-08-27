import SwiftUI


struct HueRotationGradientView: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [.purple, .yellow],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .hueRotation(.degrees(animateGradient ? 45 : 0))
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct HueRotationGradientView_Previews: PreviewProvider {
    static var previews: some View {
        HueRotationGradientView()
    }
}
