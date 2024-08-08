//
//  WeatherWidgetBundle.swift
//  WeatherWidget
//
//  Created by Michał Talaga on 08/08/2024.
//

import WidgetKit
import SwiftUI

@main
struct WeatherWidgetBundle: WidgetBundle {
    var body: some Widget {
        SimpleWeatherWidget()
        WeatherWidgetLiveActivity()
    }
}
