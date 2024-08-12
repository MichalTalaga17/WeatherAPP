//
//  Widgets.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 10/08/2024.
//

import Foundation
import WidgetKit
import SwiftUI

struct LocationWidget: Widget {
    let kind: String = "LocationWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LocationProvider()) { entry in
            LocationWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Location Widget")
        .description("Shows your current location.")
        .supportedFamilies([ .systemMedium])
    }
}

// MARK: - Forecast Widget Configuration

struct WeatherWidgetForecast: Widget {
    let kind: String = "WeatherWidgetForecast"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ForecastProvider()) { entry in
            ForecastWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Forecast Widget")
        .description("Displays weather forecast for the upcoming hours.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Basic Widget Configuration

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

// MARK: - Medium Widget Configuration

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
