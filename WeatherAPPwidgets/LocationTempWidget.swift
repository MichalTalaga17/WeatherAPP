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
/// Struktura przechowująca dane dla widgetu.
struct LocationTempWidgetEntry: TimelineEntry {
    let date: Date
    let temperature: String
    let cityName: String
    let weatherIcon: String
}

// MARK: - LocationTempWidget Provider
/// Provider dostarczający dane dla widgetu, w tym zarządzający lokalizacją i pobieraniem danych pogodowych.
struct LocationTempWidgetProvider: TimelineProvider {
    @ObservedObject private var locationManager = LocationManager()
    private let api = API.shared
    
    /// Funkcja zwracająca dane przykładowe dla widoku w trybie podglądu.
    func placeholder(in context: Context) -> LocationTempWidgetEntry {
        LocationTempWidgetEntry(date: Date(), temperature: "--", cityName: "Nieznane", weatherIcon: "01d")
    }
    
    /// Funkcja zwracająca dane dla widoku w trybie podglądu.
    func getSnapshot(in context: Context, completion: @escaping (LocationTempWidgetEntry) -> Void) {
        fetchTemperature { temperature, cityName, weatherIcon in
            let entry = LocationTempWidgetEntry(date: Date(), temperature: temperature, cityName: cityName, weatherIcon: weatherIcon)
            completion(entry)
        }
    }
    
    /// Funkcja zwracająca dane dla harmonogramu widgetu.
    func getTimeline(in context: Context, completion: @escaping (Timeline<LocationTempWidgetEntry>) -> Void) {
        fetchTemperature { temperature, cityName, weatherIcon in
            let entry = LocationTempWidgetEntry(date: Date(), temperature: temperature, cityName: cityName, weatherIcon: weatherIcon)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    /// Funkcja pobierająca temperaturę i inne dane pogodowe.
    private func fetchTemperature(completion: @escaping (String, String, String) -> Void) {
        locationManager.requestLocation { result in
            switch result {
            case .success(let location):
                print("Lokalizacja pobrana pomyślnie: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                
                if locationManager.cityName != "Unknown" {
                    print("Nazwa miasta pobrana pomyślnie: \(locationManager.cityName)")
                    
                    api.fetchCurrentWeatherData(forCity: locationManager.cityName) { result in
                        switch result {
                        case .success(let data):
                            let temperature = "\(Int(data.main.temp)) °C"
                            let weatherIcon = data.weather.first?.icon ?? "01d" // Domyślny ikon
                            print("Temperatura i ikona pobrane pomyślnie: \(temperature), \(weatherIcon)")
                            completion(temperature, locationManager.cityName, weatherIcon)
                        case .failure(let error):
                            print("Nie udało się pobrać danych pogodowych: \(error.localizedDescription)")
                            completion("--", locationManager.cityName, "01d")
                        }
                    }
                } else {
                    print("Nazwa miasta jest nieznana, nie można pobrać danych pogodowych.")
                    completion("--", "Nieznane", "01d")
                }
                
            case .failure(let error):
                print("Nie udało się pobrać lokalizacji: \(error.localizedDescription)")
                completion("--", "Nieznane", "01d")
            }
        }
    }
}

// MARK: - LocationTempWidget View
/// Widok dla widgetu, wyświetlający nazwę miasta, temperaturę i ikonę pogody.
struct LocationTempWidgetEntryView: View {
    var entry: LocationTempWidgetEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.cityName)
                    .font(.headline)
                Text(entry.temperature)
                    .font(.title2)
                Spacer()
                IconConvert(for: entry.weatherIcon, useWeatherColors: true)
                    .scaleEffect(1.3)
                    .frame(width: 60, height: 60)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - LocationTempWidget Configuration
/// Konfiguracja widgetu, w tym jego wyświetlana nazwa i opis.
struct LocationTempWidget: Widget {
    let kind: String = "LocationTempWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LocationTempWidgetProvider()) { entry in
            LocationTempWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Widget temperatury lokalizacji")
        .description("Wyświetla aktualną temperaturę i warunki pogodowe na podstawie lokalizacji.")
    }
}

// MARK: - Preview
/// Podgląd widgetu w trybie edycji.
#Preview(as: .systemSmall) {
    LocationTempWidget()
} timeline: {
    LocationTempWidgetEntry(date: Date(), temperature: "20 °C", cityName: "Miasto Przykładowe", weatherIcon: "01d")
}
