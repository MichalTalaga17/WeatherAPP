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
/// Struktura przechowująca dane dla widgetu.
struct LocationTempWidgetEntry: TimelineEntry {
    let date: Date
    let temperature: String
    let cityName: String
    let weatherIcon: String
    let humidity: String
    let windSpeed: String
    let weatherDescription: String
    let pressure: String
    let feelsLike: String
}

// MARK: - LocationTempWidget Provider
/// Provider dostarczający dane dla widgetu, w tym zarządzający lokalizacją i pobieraniem danych pogodowych.
struct LocationTempWidgetProvider: TimelineProvider {
    @ObservedObject private var locationManager = LocationManager()
    private let api = API.shared
    
    /// Funkcja zwracająca dane przykładowe dla widoku w trybie podglądu.
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
            feelsLike: "-- °C"
        )
    }
    
    /// Funkcja zwracająca dane dla widoku w trybie podglądu.
    func getSnapshot(in context: Context, completion: @escaping (LocationTempWidgetEntry) -> Void) {
        fetchTemperature { temperature, cityName, weatherIcon, humidity, windSpeed, weatherDescription, pressure, feelsLike in
            let entry = LocationTempWidgetEntry(
                date: Date(),
                temperature: temperature,
                cityName: cityName,
                weatherIcon: weatherIcon,
                humidity: humidity,
                windSpeed: windSpeed,
                weatherDescription: weatherDescription,
                pressure: pressure,
                feelsLike: feelsLike
            )
            completion(entry)
        }
    }
    
    /// Funkcja zwracająca dane dla harmonogramu widgetu.
    func getTimeline(in context: Context, completion: @escaping (Timeline<LocationTempWidgetEntry>) -> Void) {
        fetchTemperature { temperature, cityName, weatherIcon, humidity, windSpeed, weatherDescription, pressure, feelsLike in
            let entry = LocationTempWidgetEntry(
                date: Date(),
                temperature: temperature,
                cityName: cityName,
                weatherIcon: weatherIcon,
                humidity: humidity,
                windSpeed: windSpeed,
                weatherDescription: weatherDescription,
                pressure: pressure,
                feelsLike: feelsLike
            )
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                    
            
            completion(timeline)
        }
    }
    
    /// Funkcja pobierająca temperaturę i inne dane pogodowe.
    private func fetchTemperature(completion: @escaping (String, String, String, String, String, String, String, String) -> Void) {
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
                            let humidity = "\(data.main.humidity)\n%"
                            let windSpeed = "\(Int(data.wind.speed))\nkm/h"
                            let weatherDescription = data.weather.first?.description.capitalized ?? "Brak danych"
                            let pressure = "\(data.main.pressure) hPa"
                            let feelsLike = "\(Int(data.main.feels_like)) °C"
                            print("Dane pogodowe pobrane pomyślnie: \(temperature), \(weatherIcon), \(humidity), \(windSpeed), \(weatherDescription), \(pressure), \(feelsLike)")
                            completion(temperature, locationManager.cityName, weatherIcon, humidity, windSpeed, weatherDescription, pressure, feelsLike)
                        case .failure(let error):
                            print("Nie udało się pobrać danych pogodowych: \(error.localizedDescription)")
                            completion("--", locationManager.cityName, "01d", "--%", "-- km/h", "Brak danych", "-- hPa", "-- °C")
                        }
                    }
                } else {
                    print("Nazwa miasta jest nieznana, nie można pobrać danych pogodowych.")
                    completion("--", "Nieznane", "01d", "--%", "-- km/h", "Brak danych", "-- hPa", "-- °C")
                }
                
            case .failure(let error):
                print("Nie udało się pobrać lokalizacji: \(error.localizedDescription)")
                completion("--", "Nieznane", "01d", "--%", "-- km/h", "Brak danych", "-- hPa", "-- °C")
            }
        }
    }
}

// MARK: - LocationTempWidget View
/// Widok dla widgetu, wyświetlający nazwę miasta, temperaturę i inne dane pogodowe.
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
    
    var mediumView: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.cityName)
                        .font(.headline)
                    Text(entry.temperature)
                        .font(.largeTitle)
                    Text(entry.weatherDescription)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                IconConvert(for: entry.weatherIcon, useWeatherColors: true)
                    .scaleEffect(1.25)
                    .frame(width: 50, height: 50)
            }
            
            Spacer()
            
            HStack {
                HStack{
                    Image(systemName: "thermometer")
                    Text(entry.feelsLike)
                }
                HStack{
                    Image(systemName: "drop.fill")
                    Text(entry.humidity)
                }
                
                HStack{
                    Image(systemName: "wind")
                    Text(entry.windSpeed)
                }
                HStack{
                    Image(systemName: "gauge")
                    Text(entry.pressure)
                }
            }
        }
        .padding(.vertical)
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
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
/// Podgląd widgetu w trybie edycji.
#Preview(as: .systemSmall) {
    LocationTempWidget()
} timeline: {
    LocationTempWidgetEntry(date: Date(), temperature: "20 °C", cityName: "Warszawa", weatherIcon: "01d", humidity: "60%", windSpeed: "10 km/h", weatherDescription: "Czyste niebo", pressure: "1015 hPa", feelsLike: "18 °C")
}

#Preview(as: .systemMedium) {
    LocationTempWidget()
} timeline: {
    LocationTempWidgetEntry(date: Date(), temperature: "20 °C", cityName: "Warszawa", weatherIcon: "01d", humidity: "60%", windSpeed: "10 km/h", weatherDescription: "Czyste niebo", pressure: "1015 hPa", feelsLike: "18 °C")
}
