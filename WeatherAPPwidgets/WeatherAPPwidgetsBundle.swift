//
//  WeatherAPPwidgetsBundle.swift
//  WeatherAPPwidgets
//
//  Created by Michał Talaga on 22/08/2024.
//

import WidgetKit
import SwiftUI

@main
struct WeatherAPPwidgetsBundle: WidgetBundle {
    var body: some Widget {
        LocationTempWidget()
        WeatherWidget()
        ForecastWidget()
        AirQualityWidget()
        WeatherForecastPollutionWidget()
        
    }
}
