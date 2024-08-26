//
//  ForecastWidget.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 25/08/2024.
//

import SwiftUI
import WidgetKit
import CoreLocation


// MARK: - ForecastWidget Entry
/// Struktura przechowująca dane dla widgetu prognozy pogody.
struct ForecastWidgetEntry: TimelineEntry {
    let date: Date
    let forecast: [ForecastDay]
    let cityName: String
    let weatherIcon: String
}

/// Struktura przechowująca dane dla każdego dnia prognozy.
struct ForecastDay: Identifiable {
    let id = UUID()
    let date: Date
    let temperature: String
    let weatherIcon: String
}

struct ForecastWidgetProvider: TimelineProvider {
    @ObservedObject private var locationManager = LocationManager()
    private let api = API.shared
    
    /// Funkcja zwracająca dane przykładowe dla widoku w trybie podglądu.
    func placeholder(in context: Context) -> ForecastWidgetEntry {
        ForecastWidgetEntry(
            date: Date(),
            forecast: [],
            cityName: "Nieznane",
            weatherIcon: "01d"
        )
    }
    
    /// Funkcja zwracająca dane dla widoku w trybie podglądu.
    func getSnapshot(in context: Context, completion: @escaping (ForecastWidgetEntry) -> Void) {
        fetchForecast { forecast, cityName, weatherIcon in
            let entry = ForecastWidgetEntry(
                date: Date(),
                forecast: forecast,
                cityName: cityName,
                weatherIcon: weatherIcon
            )
            completion(entry)
        }
    }
    
    /// Funkcja zwracająca dane dla harmonogramu widgetu.
    func getTimeline(in context: Context, completion: @escaping (Timeline<ForecastWidgetEntry>) -> Void) {
        fetchForecast { forecast, cityName, weatherIcon in
            let entry = ForecastWidgetEntry(
                date: Date(),
                forecast: forecast,
                cityName: cityName,
                weatherIcon: weatherIcon
            )
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    /// Funkcja pobierająca prognozę pogody.
    private func fetchForecast(completion: @escaping ([ForecastDay], String, String) -> Void) {
        locationManager.requestLocation { result in
            switch result {
            case .success(_):
                api.fetchForecastData(forCity: locationManager.cityName) { result in
                    switch result {
                    case .success(let data):
                        let forecast = data.list.prefix(5).map { item in
                            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
                            let temperature = "\(Int(item.main.temp))°C"
                            let weatherIcon = item.weather.first?.icon ?? "01d"
                            return ForecastDay(date: date, temperature: temperature, weatherIcon: weatherIcon)
                        }
                        let cityName = data.city.name
                        let weatherIcon = data.list.first?.weather.first?.icon ?? "01d"
                        completion(forecast, cityName, weatherIcon)
                    case .failure(let error):
                        print("Nie udało się pobrać danych prognozy: \(error.localizedDescription)")
                        completion([], "Nieznane", "01d")
                    }
                }
            case .failure(let error):
                print("Nie udało się pobrać lokalizacji: \(error.localizedDescription)")
                completion([], "Nieznane", "01d")
            }
        }
    }
}

let hourFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH"
    return formatter
}()

struct ForecastWidgetEntryView: View {
    var entry: ForecastWidgetEntry
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(entry.cityName)
                    .font(.headline)
            }
            
            Spacer()
            
            HStack {
                ForEach(entry.forecast) { day in
                    VStack {
                        Text(hourFormatter.string(from: day.date))
                            .font(.custom("", size: 12))
                        IconConvert(for: day.weatherIcon, useWeatherColors: false)
                        Text(day.temperature)
                            .font(.callout)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(Color.blue.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - ForecastWidget Configuration
/// Konfiguracja widgetu prognozy pogody.
struct ForecastWidget: Widget {
    let kind: String = "ForecastWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ForecastWidgetProvider()) { entry in
            ForecastWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Widget prognozy pogody")
        .description("Wyświetla prognozę pogody na najbliższe dni.")
        .supportedFamilies([ .systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemMedium) {
    ForecastWidget()
} timeline: {
    ForecastWidgetEntry(
        date: Date(),
        forecast: [
            ForecastDay(date: Date(), temperature: "18°", weatherIcon: "01d"),
            ForecastDay(date: Date().addingTimeInterval(3600), temperature: "20°", weatherIcon: "02d"),
            ForecastDay(date: Date().addingTimeInterval(7200), temperature: "21°", weatherIcon: "03d"),
            ForecastDay(date: Date().addingTimeInterval(10800), temperature: "19°", weatherIcon: "04d"),
            ForecastDay(date: Date().addingTimeInterval(14400), temperature: "17°", weatherIcon: "09d")
        ],
        cityName: "Warszawa",
        weatherIcon: "01d"
    )
}
