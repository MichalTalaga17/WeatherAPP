//
//  AppIntent.swift
//  WeatherWidget
//
//  Created by Michał Talaga on 08/08/2024.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This widget shows three text parameters.")

    @Parameter(title: "First Text Parameter", default: "Hello")
    var firstText: String

    @Parameter(title: "Second Text Parameter", default: "World")
    var secondText: String

    @Parameter(title: "Third Text Parameter", default: "!")
    var thirdText: String
}
