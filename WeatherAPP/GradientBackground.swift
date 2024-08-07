//
//  gradientBackground.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 05/08/2024.
//

import Foundation
import SwiftUI

func gradientBackground(for iconName: String) -> LinearGradient {
    let iconCode = iconMap.first(where: { $0.value == iconName })?.key ?? "default"
    let isDay = iconCode.hasSuffix("d")
    print(iconName)
    switch iconName {
    case "01d":
        return LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.blue.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "01n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(0.8), Color.blue.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "02d":
        return LinearGradient(
            gradient: Gradient(colors: [ Color.gray.opacity(0.7), Color.yellow.opacity(0.2)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "02n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.black.opacity(0.6)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "03d", "03n":
        return isDay ? LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.gray.opacity(0.4)]),
            startPoint: .top,
            endPoint: .bottom
        ) : LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.35), Color.black.opacity(0.5)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "04d", "04n":
        return isDay ? LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.1), Color.gray.opacity(0.8)]),
            startPoint: .top,
            endPoint: .bottom
        ) : LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.black.opacity(0.6)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "09d", "09n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(1), Color.blue.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "10d":
        return LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.15), Color.blue.opacity(0.35)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "10n":
        return LinearGradient(
            gradient: Gradient(colors: [ Color.gray.opacity(0.7),Color.black.opacity(0.4)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "11d":
        return LinearGradient(
            gradient: Gradient(colors: [Color.white.opacity(0.5), Color.gray.opacity(0.8)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "11n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.9), Color.black.opacity(0.6)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "13d":
        return LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.white.opacity(0.7)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "13n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(0.5), Color.white.opacity(0.5) ]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "50d":
        return LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.8),Color.yellow.opacity(0.2)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "50n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.black.opacity(0.4)]),
            startPoint: .top,
            endPoint: .bottom
        )
    default:
        return isDay ? LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.4), Color.blue.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
        ) : LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(0.8), Color.blue.opacity(0.2)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

