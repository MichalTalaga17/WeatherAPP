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
    let precipitation: String // Nowe pole dla opadów
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
            precipitation: "-- mm" // Domyślna wartość opadów
        )
    }
    
    /// Funkcja zwracająca dane dla widoku w trybie podglądu.
    func getSnapshot(in context: Context, completion: @escaping (LocationTempWidgetEntry) -> Void) {
        fetchTemperature { temperature, cityName, weatherIcon, humidity, windSpeed, weatherDescription, pressure, precipitation in
            let entry = LocationTempWidgetEntry(
                date: Date(),
                temperature: temperature,
                cityName: cityName,
                weatherIcon: weatherIcon,
                humidity: humidity,
                windSpeed: windSpeed,
                weatherDescription: weatherDescription,
                pressure: pressure,
                precipitation: precipitation
            )
            completion(entry)
        }
    }
    
    /// Funkcja zwracająca dane dla harmonogramu widgetu.
    func getTimeline(in context: Context, completion: @escaping (Timeline<LocationTempWidgetEntry>) -> Void) {
        fetchTemperature { temperature, cityName, weatherIcon, humidity, windSpeed, weatherDescription, pressure, precipitation in
            let entry = LocationTempWidgetEntry(
                date: Date(),
                temperature: temperature,
                cityName: cityName,
                weatherIcon: weatherIcon,
                humidity: humidity,
                windSpeed: windSpeed,
                weatherDescription: weatherDescription,
                pressure: pressure,
                precipitation: precipitation
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
                            let temperature = "\(Int(data.main.temp))°"
                            let weatherIcon = data.weather.first?.icon ?? "01d"
                            let humidity = "\(data.main.humidity)%"
                            let windSpeed = "\(Int(data.wind.speed)) km/h"
                            let weatherDescription = data.weather.first?.description.capitalized ?? "Brak danych"
                            let pressure = "\(data.main.pressure) hPa"
                            let precipitation = "\(data.rain?.hour1 ?? 0) mm" // Nowe przetwarzanie opadów
                            completion(temperature, locationManager.cityName, weatherIcon, humidity, windSpeed, weatherDescription, pressure, precipitation)
                        case .failure(let error):
                            print("Nie udało się pobrać danych pogodowych: \(error.localizedDescription)")
                            completion("--", locationManager.cityName, "01d", "--%", "-- km/h", "Brak danych", "-- hPa", "-- mm")
                        }
                    }
                } else {
                    print("Nazwa miasta jest nieznana, nie można pobrać danych pogodowych.")
                    completion("--", "Nieznane", "01d", "--%", "-- km/h", "Brak danych", "-- hPa", "-- mm")
                }
                
            case .failure(let error):
                print("Nie udało się pobrać lokalizacji: \(error.localizedDescription)")
                completion("--", "Nieznane", "01d", "--%", "-- km/h", "Brak danych", "-- hPa", "-- mm")
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
                Spacer()
                HStack(alignment: .center, spacing: 20){
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
                HStack{
                    IconConvert(for: entry.weatherIcon, useWeatherColors: false)
                        .scaleEffect(1.2)
                }
            }
            
            Spacer()
            
            HStack {
                VStack{
                    Text(entry.temperature)
                        .font(.callout .bold())
                    Image(systemName: "thermometer")
                        .frame(width: 10, height: 10)
                }
                Spacer()
                VStack{
                    Text(entry.humidity)
                        .font(.callout .bold())
                    Image(systemName: "drop.fill")
                        .frame(width: 10, height: 10)
                }
                Spacer()
                VStack{
                    Text(entry.windSpeed)
                        .font(.callout .bold())
                    Image(systemName: "wind")
                        .frame(width: 10, height: 10)
                }
                Spacer()
                VStack{
                    Text(entry.pressure)
                        .font(.callout .bold())
                    Image(systemName: "gauge")
                        .frame(width: 10, height: 10)
                }
                Spacer()
                VStack{
                    Text(entry.precipitation)  // Wyświetlanie opadów
                        .font(.callout.bold())
                    Image(systemName: "cloud.rain.fill")
                        .frame(width: 10, height: 10)
                }
            }
            .foregroundStyle(Color.blue)
            .padding(.horizontal, 7)
            .padding(.vertical, 15)
            .background(Color.blue.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
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
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
/// Podgląd widgetu w trybie edycji.
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
