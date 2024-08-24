//
//  LocationTempWidget.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 24/08/2024.
//

import SwiftUI
import WidgetKit
import CoreLocation

// MARK: - Weather Entry

struct WeatherEntry: TimelineEntry {
    let date: Date
    let temperature: String
    let cityName: String
}

// MARK: - Weather Provider

struct WeatherProvider: TimelineProvider {
    @ObservedObject private var locationManager = LocationManager()
    private let api = API.shared
    
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), temperature: "--", cityName: "Unknown")
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        fetchTemperature { temperature, cityName in
            let entry = WeatherEntry(date: Date(), temperature: temperature, cityName: cityName)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        fetchTemperature { temperature, cityName in
            let entry = WeatherEntry(date: Date(), temperature: temperature, cityName: cityName)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    private func fetchTemperature(completion: @escaping (String, String) -> Void) {
        locationManager.requestLocation { result in
            switch result {
            case .success(let location):
                print("Location fetched successfully: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                
                if locationManager.cityName != "Unknown" {
                    print("City name fetched successfully: \(locationManager.cityName)")
                    
                    api.fetchCurrentWeatherData(forCity: locationManager.cityName) { result in
                        switch result {
                        case .success(let data):
                            let temperature = "\(Int(data.main.temp)) °C"
                            print("Temperature fetched successfully: \(temperature)")
                            completion(temperature, locationManager.cityName)
                        case .failure(let error):
                            print("Failed to fetch weather data: \(error.localizedDescription)")
                            completion("--", locationManager.cityName)
                        }
                    }
                } else {
                    print("City name is unknown, cannot fetch weather data.")
                    completion("--", "Unknown")
                }
                
            case .failure(let error):
                print("Failed to get location: \(error.localizedDescription)")
                completion("--", "Unknown")
            }
        }
    }
}

// MARK: - Weather Widget View

struct WeatherWidgetEntryView: View {
    var entry: WeatherEntry

    var body: some View {
        VStack {
            Text(entry.cityName)
                .font(.headline)
            Text(entry.temperature)
                .font(.largeTitle)
        }
    }
}

// MARK: - Weather Widget Configuration

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Weather Widget")
        .description("Displays the current temperature based on your location.")
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    WeatherEntry(date: Date(), temperature: "20", cityName: "Sample City")
}
