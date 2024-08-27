//
//  LocationWidgets.swift
//  WeatherAPPwidgets
//
//  Created by Michał Talaga on 22/08/2024.
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
    let humidity: String
    let windSpeed: String
    let weatherDescription: String
    let pressure: String
    let precipitation: String
}

// MARK: - LocationTempWidget Provider
struct LocationTempWidgetProvider: TimelineProvider {
    @ObservedObject private var locationManager = LocationManager()
    private let api = API.shared
    
    func placeholder(in context: Context) -> LocationTempWidgetEntry {
        LocationTempWidgetEntry(
            date: Date(),
            temperature: "--",
            cityName: "Nieznane",
            weatherIcon: "01d",
            humidity: "--%",
            windSpeed: "-- km/h",
            weatherDescription: "Brak danych",
            pressure: "-- hPa",
            precipitation: "-- mm"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LocationTempWidgetEntry) -> Void) {
        fetchWeatherData { entry in
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LocationTempWidgetEntry>) -> Void) {
        fetchWeatherData { entry in
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
    
    private func fetchWeatherData(completion: @escaping (LocationTempWidgetEntry) -> Void) {
        locationManager.requestLocation { result in
            switch result {
            case .success(_):
                guard locationManager.cityName != "Unknown" else {
                    completion(LocationTempWidgetEntry(
                        date: Date(),
                        temperature: "--",
                        cityName: "Nieznane",
                        weatherIcon: "01d",
                        humidity: "--%",
                        windSpeed: "-- km/h",
                        weatherDescription: "Brak danych",
                        pressure: "-- hPa",
                        precipitation: "-- mm"
                    ))
                    return
                }
                
                api.fetchCurrentWeatherData(forCity: locationManager.cityName) { result in
                    switch result {
                    case .success(let data):
                        let temperature = "\(Int(data.main.temp))°"
                        let weatherIcon = data.weather.first?.icon ?? "01d"
                        let humidity = "\(data.main.humidity)%"
                        let windSpeed = "\(Int(data.wind.speed)) km/h"
                        let weatherDescription = data.weather.first?.description.capitalized ?? "Brak danych"
                        let pressure = "\(data.main.pressure) hPa"
                        let precipitation = "\(data.rain?.hour1 ?? 0) mm"
                        let entry = LocationTempWidgetEntry(
                            date: Date(),
                            temperature: temperature,
                            cityName: locationManager.cityName,
                            weatherIcon: weatherIcon,
                            humidity: humidity,
                            windSpeed: windSpeed,
                            weatherDescription: weatherDescription,
                            pressure: pressure,
                            precipitation: precipitation
                        )
                        completion(entry)
                    case .failure(let error):
                        print("Nie udało się pobrać danych pogodowych: \(error.localizedDescription)")
                        completion(LocationTempWidgetEntry(
                            date: Date(),
                            temperature: "--",
                            cityName: locationManager.cityName,
                            weatherIcon: "01d",
                            humidity: "--%",
                            windSpeed: "-- km/h",
                            weatherDescription: "Brak danych",
                            pressure: "-- hPa",
                            precipitation: "-- mm"
                        ))
                    }
                }
            case .failure(let error):
                print("Nie udało się pobrać lokalizacji: \(error.localizedDescription)")
                completion(LocationTempWidgetEntry(
                    date: Date(),
                    temperature: "--",
                    cityName: "Nieznane",
                    weatherIcon: "01d",
                    humidity: "--%",
                    windSpeed: "-- km/h",
                    weatherDescription: "Brak danych",
                    pressure: "-- hPa",
                    precipitation: "-- mm"
                ))
            }
        }
    }
}

// MARK: - LocationTempWidget View
struct LocationTempWidgetEntryView: View {
    var entry: LocationTempWidgetEntry
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }
    
    var smallView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.cityName)
                    .font(.headline)
                Text(entry.weatherDescription)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                HStack(alignment: .center, spacing: 20) {
                    Text(entry.temperature)
                        .font(.title2.bold())
                    IconConvert(for: entry.weatherIcon, useWeatherColors: false)
                        .scaleEffect(0.8)
                        .frame(width: 30, height: 10)
                }
                .foregroundStyle(Color.blue)
                .padding(.horizontal, 7)
                .padding(.vertical, 10)
                .background(Color.blue.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var mediumView: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(entry.cityName)
                        .font(.headline)
                    Text(entry.weatherDescription)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                IconConvert(for: entry.weatherIcon, useWeatherColors: false)
                    .scaleEffect(1.2)
            }
            
            Spacer()
            
            HStack {
                weatherDataView(entry.temperature, "thermometer")
                Spacer()
                weatherDataView(entry.windSpeed, "wind")
                Spacer()
                weatherDataView(entry.pressure, "gauge")
                Spacer()
                weatherDataView(entry.humidity, "drop.fill")
                Spacer()
                weatherDataView(entry.precipitation, "cloud.rain.fill")
            }
            .foregroundStyle(Color.blue)
            .padding(.horizontal, 7)
            .padding(.vertical, 15)
            .background(Color.blue.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func weatherDataView(_ value: String, _ iconName: String) -> some View {
        VStack {
            Text(value)
                .font(.callout.bold())
            Image(systemName: iconName)
                .frame(width: 10, height: 10)
        }
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
        .configurationDisplayName("Widget temperatury lokalizacji")
        .description("Wyświetla aktualną temperaturę i warunki pogodowe na podstawie lokalizacji.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    LocationTempWidget()
} timeline: {
    LocationTempWidgetEntry(date: Date(), temperature: "20°", cityName: "Warszawa", weatherIcon: "01d", humidity: "60%", windSpeed: "10 km/h", weatherDescription: "Słonecznie", pressure: "1013 hPa", precipitation: "0 mm")
}

#Preview(as: .systemMedium) {
    LocationTempWidget()
} timeline: {
    LocationTempWidgetEntry(date: Date(), temperature: "20°", cityName: "Warszawa", weatherIcon: "01d", humidity: "60%", windSpeed: "10 km/h", weatherDescription: "Słonecznie", pressure: "1013 hPa", precipitation: "0 mm")
}
