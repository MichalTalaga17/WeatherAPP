//
//  GradientBackground.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 18/08/2024.
//

import SwiftUI
import Foundation

func gradientBackground(for iconName: String) -> LinearGradient {
    let iconCode = iconMap.first(where: { $0.value == iconName })?.key ?? "default"
    let isDay = iconCode.hasSuffix("d")
    
    switch iconName {
        // Przypadek: "01d" - Ikona słoneczna (Dzień)
        // Gradient: Jasnożółty na górze, jasnoniebieski na dole
        // Opis: Słoneczna pogoda w ciągu dnia, czyste niebo
    case "01d":
        return LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.blue.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Przypadek: "01n" - Ikona księżyc z gwiazdami (Noc)
        // Gradient: biały na górze, czarny na dole
        // Opis: Bezchmurna noc, widoczny księżyc i gwiazdy
    case "01n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.white.opacity(0.4), Color.black.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Przypadek: "02d" - Ikona słońce za chmurami (Dzień)
        // Gradient: Jasny żółty na górze, jasnoszary na dole
        // Opis: Częściowo pochmurne niebo w ciągu dnia
    case "02d":
        return LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.2), Color.gray.opacity(0.7)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Przypadek: "02n" - Ikona księżyc za chmurami (Noc)
        // Gradient: Szary na górze, ciemny czarny na dole
        // Opis: Częściowo pochmurne niebo w nocy
    case "02n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.black.opacity(0.6)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Przypadek: "03d", "03n" - Ikona chmury (Dzień i Noc)
        // Gradient: Ciemnoszary na górze, szary lub ciemny czarny na dole
        // Opis: Zachmurzone niebo, brak słońca
    case "03d", "03n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.2), isDay ? Color.gray.opacity(0.4) : Color.black.opacity(0.5)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Przypadek: "04d", "04n" - Ikona dymu lub mgły (Dzień i Noc)
        // Gradient: Żółty na górze, szary lub czarny na dole
        // Opis: Duże zachmurzenie, ciemne chmury
    case "04d", "04n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.6), isDay ? Color.gray.opacity(0.5) : Color.black.opacity(0.6)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Przypadek: "09d" - Ikona deszczu (Dzień)
            // Gradient: Ciemnoszary na górze, jasnoniebieski na dole
            // Opis: Deszczowy dzień z umiarkowanymi opadami, pochmurne niebo
            case "09d":
                return LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.blue.opacity(0.5)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            
            // Przypadek: "09n" - Ikona deszczu (Noc)
            // Gradient: Ciemnogranatowy na górze, ciemnoszary na dole
            // Opis: Deszczowa noc z umiarkowanymi opadami, ciemne chmury
            case "09n":
                return LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.gray.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
        
        // Przypadek: "10d" - Ikona deszczu ze słońcem (Dzień)
        // Gradient: Jasnożółty na górze, jasnoniebieski na dole
        // Opis: Przelotne opady deszczu w ciągu dnia
    case "10d":
        return LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.15), Color.blue.opacity(0.35)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Przypadek: "10n" - Ikona deszczu z księżycem (Noc)
        // Gradient: Szary na górze, ciemny czarny na dole
        // Opis: Przelotne opady deszczu w nocy
    case "10n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.15), Color.black.opacity(0.4)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Przypadek: "11d" - Ikona burzy (Dzień)
        // Gradient: Biały na górze, ciemnoszary na dole
        // Opis: Burza z piorunami w ciągu dnia
    case "11d":
        return LinearGradient(
            gradient: Gradient(colors: [Color.white.opacity(0.5), Color.gray.opacity(0.8)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Przypadek: "11n" - Ikona burzy (Noc)
        // Gradient: Szary na górze, ciemny czarny na dole
        // Opis: Burza z piorunami w nocy
    case "11n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.9), Color.black.opacity(0.6)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Przypadek: "13d" - Ikona śniegu (Dzień)
        // Gradient: Jasnoniebieski na górze, biały na dole
        // Opis: Opady śniegu w ciągu dnia
    case "13d":
        return LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.white.opacity(0.7)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Przypadek: "13n" - Ikona śniegu (Noc)
        // Gradient: Ciemnoczarny na górze, biały na dole
        // Opis: Opady śniegu w nocy
    case "13n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(0.5), Color.white.opacity(0.5)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Przypadek: "50d" - Ikona mgły (Dzień)
        // Gradient: Jasnoszary na górze, jasny żółty na dole
        // Opis: Mgła w ciągu dnia
    case "50d":
        return LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.2), Color.gray.opacity(0.8)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Przypadek: "50n" - Ikona mgły (Noc)
        // Gradient: Szary na górze, ciemny czarny na dole
        // Opis: Mgła w nocy
    case "50n":
        return LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.black.opacity(0.4)]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Przypadek domyślny: Jeśli ikona nie jest rozpoznana
        // Gradient: Jasnożółty lub czarny na górze, jasnoniebieski na dole
        // Opis: Neutralny gradient dla nieznanej pogody
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
