//
//  LocationTempWidget.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 24/08/2024.
//

import SwiftUI
import WidgetKit
import CoreLocation

// MARK: - LocationTempWidget Entry
struct LocationTempWidgetEntry: TimelineEntry {
    let date: Date
    let temperature: String
    let cityName: String
    let weatherIcon: String
}

// MARK: - LocationTempWidget Provider
struct LocationTempWidgetProvider: TimelineProvider {
    @ObservedObject private var locationManager = LocationManager()
    private let api = API.shared
    
    func placeholder(in context: Context) -> LocationTempWidgetEntry {
        LocationTempWidgetEntry(date: Date(), temperature: "--", cityName: "Unknown", weatherIcon: "01d")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LocationTempWidgetEntry) -> Void) {
        fetchTemperature { temperature, cityName, weatherIcon in
            let entry = LocationTempWidgetEntry(date: Date(), temperature: temperature, cityName: cityName, weatherIcon: weatherIcon)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LocationTempWidgetEntry>) -> Void) {
        fetchTemperature { temperature, cityName, weatherIcon in
            let entry = LocationTempWidgetEntry(date: Date(), temperature: temperature, cityName: cityName, weatherIcon: weatherIcon)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    private func fetchTemperature(completion: @escaping (String, String, String) -> Void) {
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
                            let weatherIcon = data.weather.first?.icon ?? "01d" // Default icon
                            print("Temperature and icon fetched successfully: \(temperature), \(weatherIcon)")
                            completion(temperature, locationManager.cityName, weatherIcon)
                        case .failure(let error):
                            print("Failed to fetch weather data: \(error.localizedDescription)")
                            completion("--", locationManager.cityName, "01d")
                        }
                    }
                } else {
                    print("City name is unknown, cannot fetch weather data.")
                    completion("--", "Unknown", "01d")
                }
                
            case .failure(let error):
                print("Failed to get location: \(error.localizedDescription)")
                completion("--", "Unknown", "01d")
            }
        }
    }
}

// MARK: - LocationTempWidget View

struct LocationTempWidgetEntryView: View {
    var entry: LocationTempWidgetEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.cityName)
                    .font(.headline)
                    .border(Color.red)
                Text(entry.temperature)
                    .font(.title2)
                    .border(Color.red)
                Spacer()
                IconConvert(for: entry.weatherIcon, useWeatherColors: true)
                    .scaleEffect(1.3)
                    .frame(width: 60, height: 60)
            }
            Spacer()
        }
        .border(Color.red)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
}

// MARK: - LocationTempWidget Configuration

struct LocationTempWidget: Widget {
    let kind: String = "LocationTempWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LocationTempWidgetProvider()) { entry in
            LocationTempWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Location Temperature Widget")
        .description("Displays the current temperature and weather conditions based on your location.")
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    LocationTempWidget()
} timeline: {
    LocationTempWidgetEntry(date: Date(), temperature: "20 °C", cityName: "Sample City", weatherIcon: "01d")
}
