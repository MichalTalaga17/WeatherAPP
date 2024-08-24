//
//  AppIntent.swift
//  WeatherAPPwidgets
//
//  Created by Michał Talaga on 22/08/2024.
//

import AppIntents

// MARK: - Weather Configuration Intent
struct WeatherConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Weather Widget Configuration"
    static var description = IntentDescription("Choose what to display in the weather widget: Humidity, Pressure, Wind Speed, Precipitation, or Cloudiness.")

    @Parameter(title: "Choose Data to Display")
    var displayOption: DisplayOption
}

// MARK: - Display Options
enum DisplayOption: String, AppEnum {
    case humidity = "Humidity"
    case pressure = "Pressure"
    case windSpeed = "Wind Speed"
    case precipitation = "Precipitation"
    case cloudiness = "Cloudiness"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Display Option")

    static var caseDisplayRepresentations: [DisplayOption: DisplayRepresentation] = [
        .humidity: DisplayRepresentation(stringLiteral: "Humidity"),
        .pressure: DisplayRepresentation(stringLiteral: "Pressure"),
        .windSpeed: DisplayRepresentation(stringLiteral: "Wind Speed"),
        .precipitation: DisplayRepresentation(stringLiteral: "Precipitation"),
        .cloudiness: DisplayRepresentation(stringLiteral: "Cloudiness")
    ]
}
