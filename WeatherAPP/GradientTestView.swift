//
//  GradientTestView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 06/08/2024.
//

import SwiftUI

struct GradientTestView: View {
    let weatherIcons = [
        "clear-day", "clear-night", "partly-cloudy-day", "partly-cloudy-night",
        "cloudy-day", "cloudy-night", "overcast-day", "overcast-night",
        "shower-day", "shower-night", "rain-day", "rain-night",
        "thunderstorm-day", "thunderstorm-night", "snow-day", "snow-night",
        "mist-day", "mist-night", "default"
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(weatherIcons, id: \.self) { iconName in
                    gradientBackground(for: iconName)
                        .frame(height: 100)
                        .overlay(
                            Text(iconName)
                                .font(.title)
                                .foregroundColor(.white)
                                .bold()
                        )
                        .padding(.bottom, 10)
                }
            }
            .padding()
        }
    }
}

#Preview{
    
        GradientTestView()
    }
