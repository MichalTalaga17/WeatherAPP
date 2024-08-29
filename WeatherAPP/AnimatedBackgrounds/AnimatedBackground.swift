//
//  AnimatedBackground.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 28/08/2024.
//

import SwiftUI

enum PrecipitationType {
    case rain, snow, hail
}

enum Cloudiness {
    case clear
    case few
    case scattered
    case broken
    case overcast
}

func animatedBackground(for iconName: String) -> some View {
    let iconCode = iconName.prefix(3)
    let isDay = iconName.hasSuffix("d")

    switch iconCode {
    case "01d", "01n":
        return AnyView(SkyView(day: isDay, cloudiness: .clear))
        
    case "02d", "02n":
        return AnyView(SkyView(day: isDay, cloudiness: .few))
        
    case "03d", "03n":
        return AnyView(SkyView(day: isDay, cloudiness: .scattered))
        
    case "04d", "04n":
        return AnyView(SkyView(day: isDay, cloudiness: .broken))
        
    case "09d", "09n":
        return AnyView(RainyDaySkyView(isDaytime: isDay, cloudiness: 0.7, precipitationType: .rain, precipitationIntensity: 150))
        
    case "10d", "10n":
        return AnyView(RainyDaySkyView(isDaytime: isDay, cloudiness: 0.8, precipitationType: .rain, precipitationIntensity: 100))
        
    case "11d", "11n":
        return AnyView(ThunderstormView(isDaytime: isDay, cloudiness: 1.0, precipitationType: .rain, precipitationIntensity: 200))
        
    case "13d", "13n":
        return AnyView(RainyDaySkyView(isDaytime: isDay, cloudiness: 0.9, precipitationType: .snow, precipitationIntensity: 300))
        
    case "50d", "50n":
        return AnyView(FoggyView(isDaytime: isDay))
        
    default:
        return AnyView(Color.clear)
    }
}

// Example FoggyView for Mist (50d and 50n)
struct FoggyView: View {
    let isDaytime: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: isDaytime
                    ? [Color.white.opacity(0.7), Color.gray.opacity(0.5)]
                    : [Color.gray.opacity(0.7), Color.black.opacity(0.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Rectangle()
                .fill(Color.white.opacity(0.2))
                .blur(radius: 10)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

// Example Usage
#Preview {
    animatedBackground(for: "11d")
}
