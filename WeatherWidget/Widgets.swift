//
//  Widgets.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 10/08/2024.
//

import Foundation
import WidgetKit
import SwiftUI

// MARK: - Konfiguracja widgetu prognozy

struct WeatherWidgetForecast: Widget {
    let kind: String = "WeatherWidgetForecast"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ForecastProvider()) { entry in
            ForecastWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Prognoza Pogody")
        .description("Wyświetla prognozę pogody na kilka nadchodzących godzin.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Konfiguracja widgetu podstawowego

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Small Weather Widget")
        .description("Shows basic weather information.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Konfiguracja widgetu średniego

struct WeatherWidgetMedium: Widget {
    let kind: String = "WeatherWidgetMedium"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetMediumEntryView(entry: entry)
        }
        .configurationDisplayName("Medium Weather Widget")
        .description("Shows more detailed weather information.")
        .supportedFamilies([.systemMedium])
    }
}
