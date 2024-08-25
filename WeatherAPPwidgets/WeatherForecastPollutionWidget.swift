//
//  WeatherForecastPollutionWidget.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 25/08/2024.
//

import Foundation
import SwiftUI
import WidgetKit

// MARK: - WeatherForecastPollutionEntry
struct WeatherForecastPollutionEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let currentTemperature: String
    let weatherIcon: String
    let forecast: [ForecastDay]
    let aqi: Int
    let aqiDescription: String
    let pm25: Double
    let pm10: Double
}

struct WeatherForecastPollutionProvider: TimelineProvider {
    private let api = API.shared
    
    func placeholder(in context: Context) -> WeatherForecastPollutionEntry {
        WeatherForecastPollutionEntry(
            date: Date(),
            cityName: "Unknown",
            currentTemperature: "--",
            weatherIcon: "01d",
            forecast: [],
            aqi: 0,
            aqiDescription: "Unknown",
            pm25: 0.0,
            pm10: 0.0
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeatherForecastPollutionEntry) -> Void) {
        fetchCombinedData { entry in
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherForecastPollutionEntry>) -> Void) {
        fetchCombinedData { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    private func fetchCombinedData(completion: @escaping (WeatherForecastPollutionEntry) -> Void) {
        // Replace "Your City" with a valid city name or fetch it from a stored setting
        let city = "Your City"
        
        api.fetchForecastData(forCity: city) { forecastResult in
            switch forecastResult {
            case .success(let forecastData):
                api.fetchAirPollutionData(forCity: city) { pollutionResult in
                    switch pollutionResult {
                    case .success(let pollutionData):
                        let latestEntry = pollutionData.list.first ?? PollutionEntry(main: MainPollution(aqi: 0), components: PollutionComponents(co: 0, no: 0, no2: 0, o3: 0, so2: 0, pm2_5: 0, pm10: 0, nh3: 0))
                        let forecast = forecastData.list.prefix(5).map { item in
                            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
                            let temperature = "\(Int(item.main.temp)) °C"
                            let weatherIcon = item.weather.first?.icon ?? "01d"
                            return ForecastDay(date: date, temperature: temperature, weatherIcon: weatherIcon)
                        }
                        
                        let entry = WeatherForecastPollutionEntry(
                            date: Date(),
                            cityName: forecastData.city.name,
                            currentTemperature: "\(Int(forecastData.list.first?.main.temp ?? 0)) °C",
                            weatherIcon: forecastData.list.first?.weather.first?.icon ?? "01d",
                            forecast: forecast,
                            aqi: latestEntry.main.aqi,
                            aqiDescription: aqiDescription(for: latestEntry.main.aqi),
                            pm25: latestEntry.components.pm2_5,
                            pm10: latestEntry.components.pm10
                        )
                        completion(entry)
                        
                    case .failure(let error):
                        print("Failed to fetch pollution data: \(error.localizedDescription)")
                        let entry = WeatherForecastPollutionEntry(
                            date: Date(),
                            cityName: forecastData.city.name,
                            currentTemperature: "\(Int(forecastData.list.first?.main.temp ?? 0)) °C",
                            weatherIcon: forecastData.list.first?.weather.first?.icon ?? "01d",
                            forecast: [],
                            aqi: 0,
                            aqiDescription: "Unknown",
                            pm25: 0.0,
                            pm10: 0.0
                        )
                        completion(entry)
                    }
                }
                
            case .failure(let error):
                print("Failed to fetch forecast data: \(error.localizedDescription)")
                let entry = WeatherForecastPollutionEntry(
                    date: Date(),
                    cityName: "Unknown",
                    currentTemperature: "--",
                    weatherIcon: "01d",
                    forecast: [],
                    aqi: 0,
                    aqiDescription: "Unknown",
                    pm25: 0.0,
                    pm10: 0.0
                )
                completion(entry)
            }
        }
    }
    func aqiDescription(for aqi: Int) -> String {
        switch aqi {
        case 1:
            return "Good"
        case 2:
            return "Fair"
        case 3:
            return "Moderate"
        case 4:
            return "Poor"
        case 5:
            return "Very Poor"
        default:
            return "Unknown"
        }
    }
}
struct WeatherForecastPollutionEntryView: View {
    var entry: WeatherForecastPollutionEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(entry.cityName)
                    .font(.headline)
                Spacer()
                VStack(alignment: .trailing) {
                    Text(entry.currentTemperature)
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    Image(systemName: entry.weatherIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
            }
            
            Spacer().frame(height: 10)
            
            HStack {
                ForEach(entry.forecast) { day in
                    VStack {
                        Text(hourFormatter.string(from: day.date))
                            .font(.footnote)
                        Image(systemName: day.weatherIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text(day.temperature)
                            .font(.footnote)
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            Spacer().frame(height: 10)
            
            VStack(alignment: .leading) {
                Text("Air Quality: \(entry.aqiDescription)")
                    .font(.subheadline)
                    .foregroundColor(entry.aqiColor())
                Text("PM2.5: \(entry.pm25, specifier: "%.1f") µg/m³")
                    .font(.footnote)
                Text("PM10: \(entry.pm10, specifier: "%.1f") µg/m³")
                    .font(.footnote)
            }
            .padding(10)
            .background(Color.accentColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
    }
}

extension WeatherForecastPollutionEntry {
    func aqiColor() -> Color {
        switch aqi {
        case 1:
            return .green
        case 2:
            return .yellow
        case 3:
            return .orange
        case 4:
            return .red
        case 5:
            return .purple
        default:
            return .gray
        }
    }
}
struct WeatherForecastPollutionWidget: Widget {
    let kind: String = "WeatherForecastPollutionWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherForecastPollutionProvider()) { entry in
            WeatherForecastPollutionEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Weather, Forecast & Air Quality Widget")
        .description("Displays current weather, forecast, and air quality information for a selected city.")
        .supportedFamilies([.systemLarge])
    }
}
#Preview(as: .systemLarge) {
    WeatherForecastPollutionWidget()
} timeline: {
    WeatherForecastPollutionEntry(
        date: Date(),
        cityName: "Warszawa",
        currentTemperature: "22 °C",
        weatherIcon: "01d",
        forecast: [
            ForecastDay(date: Date(), temperature: "20°C", weatherIcon: "01d"),
            ForecastDay(date: Date().addingTimeInterval(3600 * 24), temperature: "18°C", weatherIcon: "02d"),
            ForecastDay(date: Date().addingTimeInterval(3600 * 24 * 2), temperature: "19°C", weatherIcon: "03d")
        ],
        aqi: 2,
        aqiDescription: "Fair",
        pm25: 12.5,
        pm10: 25.0
    )
}
