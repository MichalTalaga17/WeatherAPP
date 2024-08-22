//
//  SharedViews.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 22/08/2024.
//

import SwiftUI

struct WeatherDetailRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
        .padding()
    }
}

struct PollutionDataView: View {
    var pollution: PollutionData?
    
    var body: some View {
        VStack {
            if let pollution = pollution {
                Text("Air Quality Index: \(pollution.aqi ?? 0)")
                    .font(.headline)
                // Additional pollution details here
            } else {
                Text("Loading pollution data...")
            }
        }
        .padding()
    }
}

struct GradientBackground: View {
    var icon: String
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple]),
            startPoint: .top,
            endPoint: .bottom
        )
        .opacity(0.6)
    }
}

func gradientBackground(for icon: String) -> some View {
    GradientBackground(icon: icon)
}

#Preview {
    GradientBackground(icon: "01d")
}
