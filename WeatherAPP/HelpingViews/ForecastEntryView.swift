//
//  ForecastEntryView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 21/08/2024.
//

import SwiftUI

struct ForecastEntryView: View {
    let forecastEntry: ForecastEntry
    
    var body: some View {
        VStack {
            Text(extractHour(from: forecastEntry.dt_txt))
                .font(.caption)
            IconConvert(for: forecastEntry.weather.first?.icon ?? "", useWeatherColors: true)
            Text("\(Int(forecastEntry.main.temp))°")
                .font(.title2.bold())
            Text("\(Int(forecastEntry.main.feels_like))°")
                .font(.callout)
        }
        .frame(width: UIScreen.main.bounds.width * 0.15)
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(8)
    }
}
