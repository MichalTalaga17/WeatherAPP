//
//  WeatherAPPwidgets.swift
//  WeatherAPPwidgets
//
//  Created by Michał Talaga on 22/08/2024.
//

import WidgetKit
import SwiftUI
import CoreLocation

struct WeatherEntry: TimelineEntry {
    var date: Date
    let cityName: String
    let value: String
    let displayOption: DisplayOption
}


struct WeatherProvider: AppIntentTimelineProvider {
    @ObservedObject private var locationManager = LocationManager()
    private let api = API.shared

    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), cityName: "Unknown", value: "--", displayOption: .humidity)
    }

    func snapshot(for configuration: WeatherConfigurationIntent, in context: Context) async -> WeatherEntry {
        await fetchWeatherData(for: configuration)
    }

    func timeline(for configuration: WeatherConfigurationIntent, in context: Context) async -> Timeline<WeatherEntry> {
        let entry = await fetchWeatherData(for: configuration)
        return Timeline(entries: [entry], policy: .atEnd)
    }

    private func fetchWeatherData(for configuration: WeatherConfigurationIntent) async -> WeatherEntry {
        let currentDate = Date()
        let displayOption = configuration.displayOption
        
        return await withCheckedContinuation { continuation in
            locationManager.requestLocation { result in
                switch result {
                case .success(_):
                    guard locationManager.cityName != "Unknown" else {
                        continuation.resume(returning: WeatherEntry(date: currentDate, cityName: "Unknown", value: "--", displayOption: displayOption))
                        return
                    }
                    
                    api.fetchCurrentWeatherData(forCity: locationManager.cityName) { result in
                        switch result {
                        case .success(let data):
                            let value: String
                            switch displayOption {
                            case .humidity:
                                value = "\(data.main.humidity)%"
                            case .pressure:
                                value = "\(data.main.pressure) hPa"
                            case .windSpeed:
                                value = "\(data.wind.speed) m/s"
                            case .precipitation:
                                value = "\(data.rain?.hour1 ?? 0) mm"
                            case .cloudiness:
                                value = "\(data.clouds.all)%"
                            }
                            continuation.resume(returning: WeatherEntry(date: currentDate, cityName: locationManager.cityName, value: value, displayOption: displayOption))
                        case .failure:
                            continuation.resume(returning: WeatherEntry(date: currentDate, cityName: locationManager.cityName, value: "--", displayOption: displayOption))
                        }
                    }
                case .failure:
                    continuation.resume(returning: WeatherEntry(date: currentDate, cityName: "Unknown", value: "--", displayOption: displayOption))
                }
            }
        }
    }
}

struct WeatherEntryView: View {
    var entry: WeatherProvider.Entry

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.cityName)
                    .font(.headline)
                Text(entry.displayOption.displayName)
                    .font(.caption)
                Spacer()
                VStack(alignment: .leading) {
                    Text(entry.value)
                        .font(.title.bold())
                        .foregroundStyle(Color.blue)
                    
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .background(Color.blue.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Spacer()
        }
    }
}

extension DisplayOption {
    var displayName: String {
        switch self {
        case .humidity:
            return "Humidity"
        case .pressure:
            return "Pressure"
        case .windSpeed:
            return "Wind Speed"
        case .precipitation:
            return "Precipitation"
        case .cloudiness:
            return "Cloudiness"
        }
    }
}

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: WeatherConfigurationIntent.self, provider: WeatherProvider()) { entry in
            WeatherEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Weather Widget")
        .description("Displays various weather metrics based on your selection.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    WeatherEntry(date: Date(), cityName: "Warszawa", value: "1200 hPa", displayOption: .precipitation )
}
