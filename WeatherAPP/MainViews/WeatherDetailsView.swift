//
//  WeatherDetailsView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 19/08/2024.
//

import SwiftUI

// MARK: - Detailed Weather View
struct WeatherDetailsView: View {
    let weather: CurrentData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current Weather")
                .font(.headline)
                .padding(.top)
            
            ExtractedView( weather: weather)
        }
    }
}

struct ExtractedView: View {
    @AppStorage("iconsColorsBasedOnWeather") private var iconsColorsBasedOnWeather: Bool = true
    
    let weather: CurrentData
    var body: some View {
        Group {
            WeatherDetailRow(title: "Temperature", value: "\(Int(weather.main.temp))°C")
            WeatherDetailRow(title: "Feels Like", value: "\(Int(weather.main.feels_like))°C")
            WeatherDetailRow(title: "Min Temp", value: "\(Int(weather.main.temp_min))°C")
            WeatherDetailRow(title: "Max Temp", value: "\(Int(weather.main.temp_max))°C")
            WeatherDetailRow(title: "Humidity", value: "\(weather.main.humidity)%")
            WeatherDetailRow(title: "Pressure", value: "\(weather.main.pressure) hPa")
            WeatherDetailRow(title: "Cloudiness", value: "\(weather.clouds.all)%")
            WeatherDetailRow(title: "Visibility", value: "\(weather.visibility / 1000) km")
            WeatherDetailRow(title: "Wind Speed", value: "\(Int(weather.wind.speed)) m/s")
            
            if let rain = weather.rain?.hour1 {
                WeatherDetailRow(title: "Rain", value: "\(rain) mm (1h)")
            }
            if let snow = weather.snow?.hour1 {
                WeatherDetailRow(title: "Snow", value: "\(snow) mm (1h)")
            }
            
            WeatherDetailRow(title: "Sunrise", value: formatUnixTimeToHourAndMinute(weather.sys.sunrise, timezone: weather.timezone))
            WeatherDetailRow(title: "Sunset", value: formatUnixTimeToHourAndMinute(weather.sys.sunset, timezone: weather.timezone))
            if let weatherDescription = weather.weather.first?.description {
                WeatherDetailRow(title: "Description", value: weatherDescription.capitalized)
            }
            if let icon = weather.weather.first?.icon {
                IconConvert(for: icon, iconsColorsBasedOnWeather)
            }
        }
        .padding(.horizontal)
    }
}
