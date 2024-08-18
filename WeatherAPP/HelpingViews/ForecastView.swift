//
//  ForecastView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 18/08/2024.
//

import SwiftUI

struct ForecastView: View {
    let forecast: ForecastData
    let iconsColorsBasedOnWeather: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Forecast")
                .font(.headline)
                .padding(.top)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(forecast.list.prefix(10), id: \.dt) { entry in
                        VStack {
                            Text("\(extractHour(from: entry.dt_txt))")
                            IconConvert(for: entry.weather.first?.icon ?? "", useWeatherColors: iconsColorsBasedOnWeather)
                            Text("\(Int(entry.main.temp))°")
                            Text("\(Int(entry.main.feels_like))°")
                        }
                    }
                }
            }
        }
        .padding()
    }
}

