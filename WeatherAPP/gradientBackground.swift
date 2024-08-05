//
//  gradientBackground.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 05/08/2024.
//

import Foundation
import SwiftUI

func gradientBackground(for iconName: String) -> LinearGradient {
    // Mapowanie ikon systemowych na kody pogody
    let iconCode = iconMap.first(where: { $0.value == iconName })?.key ?? "default"
    
    switch iconCode {
    case "01d":
        return LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.7)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "01n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(0.8), Color.blue.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "02d", "02n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.7)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "03d", "03n", "04d", "04n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.8)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "09d", "09n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.gray.opacity(0.5)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "10d", "10n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.gray.opacity(0.6)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "11d", "11n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.black.opacity(0.5)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "13d", "13n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.white.opacity(0.7), Color.blue.opacity(0.4)]),
            startPoint: .top,
            endPoint: .bottom
        )
    case "50d", "50n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.blue.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
        )
    default:
        return LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(0.8), Color.blue.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
