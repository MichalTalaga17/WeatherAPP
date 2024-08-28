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

func animatedBackground(for iconName: String) -> LinearGradient {
    let iconCode = iconMap.first(where: { $0.value == iconName })?.key ?? "default"
    let isDay = iconCode.hasSuffix("d")
    
    let gradient: LinearGradient
    
    switch iconName {
    case "01d":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.blue.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    case "01n":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.white.opacity(0.4), Color.black.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    case "02d":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.2), Color.gray.opacity(0.7)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    case "02n":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.black.opacity(0.6)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    case "03d", "03n":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.2), isDay ? Color.gray.opacity(0.4) : Color.black.opacity(0.5)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    case "04d", "04n":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.6), isDay ? Color.gray.opacity(0.5) : Color.black.opacity(0.6)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    case "09d":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.blue.opacity(0.5)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    case "09n":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.gray.opacity(0.7)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    case "10d":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.15), Color.blue.opacity(0.35)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    case "10n":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.15), Color.black.opacity(0.4)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    case "11d":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.white.opacity(0.5), Color.gray.opacity(0.8)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    case "11n":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.9), Color.black.opacity(0.6)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    case "13d":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.white.opacity(0.7), Color.blue.opacity(0.2)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    case "13n":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(0.5), Color.white.opacity(0.5)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    case "50d":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.2), Color.gray.opacity(0.8)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    case "50n":
        gradient = LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.black.opacity(0.4)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
    default:
        gradient = isDay ? LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.4), Color.blue.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
        ) : LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(0.8), Color.blue.opacity(0.2)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    return gradient
}
