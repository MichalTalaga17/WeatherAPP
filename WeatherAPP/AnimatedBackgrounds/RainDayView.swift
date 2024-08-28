//
//  RainDayView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 28/08/2024.
//

import Foundation
import SwiftUI

// Sun hidden behind clouds
private struct HiddenSun: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 150, height: 150)
                .blur(radius: 30)
        }
    }
}

// Realistic Cloud Shape with multiple layers
private struct RainCloud: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.gray.opacity(0.7))
                .frame(width: 250, height: 100)
                .blur(radius: 50)
            Ellipse()
                .fill(Color.gray.opacity(0.6))
                .frame(width: 200, height: 80)
                .blur(radius: 40)
                .offset(x: 40, y: -20)
            Ellipse()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 150, height: 60)
                .blur(radius: 30)
                .offset(x: -60, y: 10)
            Ellipse()
                .fill(Color.gray.opacity(0.8))
                .frame(width: 160, height: 60)
                .blur(radius: 30)
                .offset(x: 20, y: 30)
        }
        .opacity(0.85)
    }
}

// Raindrop Animation
private struct Raindrop: View {
    @State private var dropFall = false

    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.5))
            .frame(width: 3, height: 10)
            .offset(y: dropFall ? 300 : -100)
            .onAppear {
                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                    dropFall = true
                }
            }
    }
}

// Rainfall Effect
private struct Rainfall: View {
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { _ in
                Raindrop()
                    .offset(x: CGFloat.random(in: -200...200))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: UUID())
            }
        }
    }
}

// RainyDaySkyView with hidden sun, dark clouds, and falling rain
struct RainyDaySkyView: View {
    var body: some View {
        ZStack {
            // Dark stormy sky
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.3, green: 0.3, blue: 0.4),
                    Color(red: 0.2, green: 0.2, blue: 0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Hidden Sun behind the clouds
            HiddenSun()
                .offset(x: -100, y: -300)

            // Dark Rain Clouds
            RainCloud()
                .offset(x: -150, y: -200)
            RainCloud()
                .offset(x: 180, y: -250)
            RainCloud()
                .offset(x: 80, y: -100)

            // Rainfall animation
            Rainfall()
                .offset(y: -50)
        }
    }
}

// Preview
#Preview {
    RainyDaySkyView()
}
