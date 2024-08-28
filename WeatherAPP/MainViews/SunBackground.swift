//
//  SunBackground.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 28/08/2024.
//

import SwiftUI

// Sun Shape
private struct Sun: View {
    var body: some View {
        Circle()
            .fill(LinearGradient(gradient: Gradient(colors: [Color.white, Color.yellow.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
            .frame(width: 120, height: 120)
            .blur(radius: 20)
            .overlay(
                Circle()
                    .stroke(LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.6), Color.orange.opacity(0.3)]), startPoint: .top, endPoint: .bottom), lineWidth: 4)
                    .frame(width: 130, height: 130)
            )
    }
}

// Cloud Shape
private struct Cloud: View {
    var body: some View {
        Ellipse()
            .fill(Color.white.opacity(0.8))
            .frame(width: 150, height: 60)
            .blur(radius: 10)
            .overlay(
                Ellipse()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 100, height: 40)
                    .offset(x: 50, y: -20)
            )
            .overlay(
                Ellipse()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 70, height: 30)
                    .offset(x: -50, y: 10)
            )
    }
}

// DaySkyView
struct DaySkyView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.3, green: 0.7, blue: 1.0),
                    Color(red: 0.6, green: 0.9, blue: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Sun
            Sun()
                .offset(x: 0, y: -200)
            
            // Clouds
            Cloud()
                .offset(x: -100, y: -50)
                .animation(.linear(duration: 40).repeatForever(autoreverses: true), value: UUID())
            Cloud()
                .offset(x: 150, y: -150)
                .animation(.linear(duration: 50).repeatForever(autoreverses: true), value: UUID())
            Cloud()
                .offset(x: 50, y: 50)
                .animation(.linear(duration: 30).repeatForever(autoreverses: true), value: UUID())
        }
    }
}

// Preview
#Preview {
    DaySkyView()
}

