//
//  Icons.swift
//  WeatherAPP
//
//  Created by Michał Talaga
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
    "01n": [.gray, .white],
    "02d": [.white, .yellow],
    "02n": [.white, .gray],
    "03d": [.white],
    "03n": [.white],
    "04d": [.white],
    "04n": [.white],
    "09d": [.white, .blue],
    "09n": [.white, .blue],
    "10d": [.white, .yellow, .blue],
    "10n": [.white, .gray, .blue],
    "11d": [.white, .blue],
    "11n": [.white, .blue],
    "13d": [.white, .gray],
    "13n": [.white, .gray],
    "50d": [.white, .gray],
    "50n": [.white, .gray],
]

func weatherIcon(for iconName: String, primaryColor: Color? = nil, secondaryColor: Color? = nil, tertiaryColor: Color? = nil) -> some View {
    let sfSymbolName = iconMap[iconName] ?? "questionmark.circle.fill"
    
    var colors: [Color] = []
    
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
    
    let icon = Image(systemName: sfSymbolName)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 40, height: 40)
        .symbolRenderingMode(.palette)
    
    let styledIcon: AnyView
    switch colors.count {
    case 1:
        styledIcon = AnyView(icon.foregroundStyle(colors[0]))
    case 2:
        styledIcon = AnyView(icon.foregroundStyle(colors[0], colors[1]))
    case 3:
        styledIcon = AnyView(icon.foregroundStyle(colors[0], colors[1], colors[2]))
    default:
        styledIcon = AnyView(icon.foregroundStyle(.primary))
    }
    
    return styledIcon
}
