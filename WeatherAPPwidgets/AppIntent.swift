//
//  AppIntent.swift
//  WeatherAPPwidgets
//
//  Created by Michał Talaga on 22/08/2024.
//

import WidgetKit
import AppIntents
import SwiftUI

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Choose city:", default: "Warszawa")
    var choosenCity: String
}

struct WeatherConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Weather Widget Configuration"
    static var description = IntentDescription("Choose what to display in the weather widget: Humidity or Pressure.")

    @Parameter(title: "Choose Data to Display")
    var displayOption: DisplayOption
}

enum DisplayOption: String, AppEnum {
    case humidity = "Humidity"
    case pressure = "Pressure"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Display Option")

    static var caseDisplayRepresentations: [DisplayOption: DisplayRepresentation] = [
        .humidity: DisplayRepresentation(stringLiteral: "Humidity"),
        .pressure: DisplayRepresentation(stringLiteral: "Pressure")
    ]
}
