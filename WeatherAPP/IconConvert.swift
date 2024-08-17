//
//  IconConvert.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import Foundation
import SwiftUI

let iconMap: [String: String] = [
    "01d": "sun.max.fill",
    "01n": "moon.stars.fill",
    "02d": "cloud.sun.fill",
    "02n": "cloud.moon.fill",
    "03d": "cloud.fill",
    "03n": "cloud.fill",
    "04d": "smoke.fill",
    "04n": "smoke.fill",
    "09d": "cloud.rain.fill",
    "09n": "cloud.rain.fill",
    "10d": "cloud.sun.rain.fill",
    "10n": "cloud.moon.rain.fill",
    "11d": "cloud.bolt.rain.fill",
    "11n": "cloud.bolt.rain.fill",
    "13d": "cloud.snow.fill",
    "13n": "cloud.snow.fill",
    "50d": "cloud.fog.fill",
    "50n": "cloud.fog.fill",
]

let iconColorsMap: [String: [Color]] = [
    "01d": [.yellow],
    "01n": [.gray, .clouds],
    "02d": [.clouds, .yellow],
    "02n": [.clouds, .gray],
    "03d": [.clouds],
    "03n": [.clouds],
    "04d": [.clouds],
    "04n": [.clouds],
    "09d": [.clouds, .blue],
    "09n": [.clouds, .blue],
    "10d": [.clouds, .yellow, .blue],
    "10n": [.clouds, .gray, .blue],
    "11d": [.clouds, .blue],
    "11n": [.clouds, .blue],
    "13d": [.clouds, .gray],
    "13n": [.clouds, .gray],
    "50d": [.clouds, .gray],
    "50n": [.clouds, .gray],
]

func IconConvert(for iconName: String, useWeatherColors: Bool, primaryColor: Color? = nil, secondaryColor: Color? = nil, tertiaryColor: Color? = nil) -> some View {
    let sfSymbolName = iconMap[iconName] ?? "questionmark.circle.fill"
    
    var colors: [Color] = []
    
    if useWeatherColors {
        if let primaryColor = primaryColor {
            colors.append(primaryColor)
        }
        if let secondaryColor = secondaryColor {
            colors.append(secondaryColor)
        }
        if let tertiaryColor = tertiaryColor {
            colors.append(tertiaryColor)
        }
        
        if colors.isEmpty {
            colors = iconColorsMap[iconName] ?? [.primary]
        }
    }
    
    let icon = Image(systemName: sfSymbolName)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 40, height: 40)
    
    if useWeatherColors && !colors.isEmpty {
        let styledIcon: AnyView
        switch colors.count {
        case 1:
            styledIcon = AnyView(icon.symbolRenderingMode(.palette).foregroundStyle(colors[0]))
        case 2:
            styledIcon = AnyView(icon.symbolRenderingMode(.palette).foregroundStyle(colors[0], colors[1]))
        case 3:
            styledIcon = AnyView(icon.symbolRenderingMode(.palette).foregroundStyle(colors[0], colors[1], colors[2]))
        default:
            styledIcon = AnyView(icon.symbolRenderingMode(.palette).foregroundStyle(.primary))
        }
        return styledIcon
    } else {
        return AnyView(icon.foregroundStyle(.primary))
    }
}
