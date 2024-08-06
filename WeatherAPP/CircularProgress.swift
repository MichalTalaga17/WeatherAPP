//
//  CircularProgress.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 06/08/2024.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let gradientColors: [Color]
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.white.opacity(0.05),
                    lineWidth: 30
                )
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: .degrees(-100),
                        endAngle: .degrees(350)
                    ),
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
            
            Text(String(format: "%.0f%%", progress * 100))
                .font(.title)
                .bold()
                .foregroundColor(.clear)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(
                        Text(String(format: "%.0f%%", progress * 100))
                            .font(.title)
                            .bold()
                    )
                )
        }
        .padding()
    }
}

