//
//  WeatherWidgetBundle.swift
//  WeatherWidget
//
//  Created by Michał Talaga on 08/08/2024.
//

import WidgetKit
import SwiftUI

@main
struct WeatherWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        WeatherWidget()          // Mały widżet
        WeatherWidgetMedium()    // Średni widżet
        WeatherWidgetForecast()  // Widżet prognozy
        LocationWidget()         // Widżet lokalizacji
    }
}
