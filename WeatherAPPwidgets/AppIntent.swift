//
//  AppIntent.swift
//  WeatherAPPwidgets
//
//  Created by Michał Talaga on 22/08/2024.
//

import AppIntents

struct WeatherConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Weather Widget Configuration"
    static var description = IntentDescription("Choose what to display in the weather widget: Humidity, Pressure, Wind Speed, Precipitation, Cloudiness, or Sunrise & Sunset.")

    @Parameter(title: "Choose Data to Display")
    var displayOption: DisplayOption
}

enum DisplayOption: String, AppEnum {
    case humidity = "Humidity"
    case pressure = "Pressure"
    case windSpeed = "Wind Speed"
    case precipitation = "Precipitation"
    case cloudiness = "Cloudiness"
    case sunriseSunset = "Sunrise & Sunset"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Display Option")

    static var caseDisplayRepresentations: [DisplayOption: DisplayRepresentation] = [
        .humidity: DisplayRepresentation(stringLiteral: "Humidity"),
        .pressure: DisplayRepresentation(stringLiteral: "Pressure"),
        .windSpeed: DisplayRepresentation(stringLiteral: "Wind Speed"),
        .precipitation: DisplayRepresentation(stringLiteral: "Precipitation"),
        .cloudiness: DisplayRepresentation(stringLiteral: "Cloudiness"),
        .sunriseSunset: DisplayRepresentation(stringLiteral: "Sunrise & Sunset")
    ]
}
