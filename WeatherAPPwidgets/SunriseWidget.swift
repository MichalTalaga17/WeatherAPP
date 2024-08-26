//
//  SunriseSunsetWidget.swift
//  WeatherAPPwidgets
//
//  Created by Michał Talaga on 22/08/2024.
//

import SwiftUI
import WidgetKit
import CoreLocation

// MARK: - SunriseSunsetWidget Entry
/// Struktura przechowująca dane dla widgetu.
struct SunriseSunsetWidgetEntry: TimelineEntry {
    let date: Date
    let sunriseTime: String
    let sunsetTime: String
    let cityName: String
    let weatherIcon: String
    let weatherDescription: String
}

// MARK: - SunriseSunsetWidget Provider
/// Provider dostarczający dane dla widgetu, w tym zarządzający lokalizacją i pobieraniem danych pogodowych.
struct SunriseSunsetWidgetProvider: TimelineProvider {
    @ObservedObject private var locationManager = LocationManager()
    private let api = API.shared
    
    /// Funkcja zwracająca dane przykładowe dla widoku w trybie podglądu.
    func placeholder(in context: Context) -> SunriseSunsetWidgetEntry {
        SunriseSunsetWidgetEntry(
            date: Date(),
            sunriseTime: "--:--",
            sunsetTime: "--:--",
            cityName: "Nieznane",
            weatherIcon: "01d",
            weatherDescription: "Brak danych"
        )
    }
    
    /// Funkcja zwracająca dane dla widoku w trybie podglądu.
    func getSnapshot(in context: Context, completion: @escaping (SunriseSunsetWidgetEntry) -> Void) {
        fetchSunriseSunset { sunriseTime, sunsetTime, cityName, weatherIcon, weatherDescription in
            let entry = SunriseSunsetWidgetEntry(
                date: Date(),
                sunriseTime: sunriseTime,
                sunsetTime: sunsetTime,
                cityName: cityName,
                weatherIcon: weatherIcon,
                weatherDescription: weatherDescription
            )
            completion(entry)
        }
    }
    
    /// Funkcja zwracająca dane dla harmonogramu widgetu.
    func getTimeline(in context: Context, completion: @escaping (Timeline<SunriseSunsetWidgetEntry>) -> Void) {
        fetchSunriseSunset { sunriseTime, sunsetTime, cityName, weatherIcon, weatherDescription in
            let entry = SunriseSunsetWidgetEntry(
                date: Date(),
                sunriseTime: sunriseTime,
                sunsetTime: sunsetTime,
                cityName: cityName,
                weatherIcon: weatherIcon,
                weatherDescription: weatherDescription
            )
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
    
    /// Funkcja pobierająca czas wschodu i zachodu słońca oraz inne dane pogodowe.
    private func fetchSunriseSunset(completion: @escaping (String, String, String, String, String) -> Void) {
        locationManager.requestLocation { result in
            switch result {
            case .success(let location):
                print("Lokalizacja pobrana pomyślnie: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                
                if locationManager.cityName != "Unknown" {
                    print("Nazwa miasta pobrana pomyślnie: \(locationManager.cityName)")
                    
                    api.fetchCurrentWeatherData(forCity: locationManager.cityName) { result in
                        switch result {
                        case .success(let data):
                            let formatter = DateFormatter()
                            formatter.timeStyle = .short
                            formatter.timeZone = TimeZone(secondsFromGMT: data.timezone)
                            
                            let sunriseTime = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(data.sys.sunrise)))
                            let sunsetTime = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(data.sys.sunset)))
                            let weatherIcon = data.weather.first?.icon ?? "01d"
                            let weatherDescription = data.weather.first?.description.capitalized ?? "Brak danych"
                            
                            completion(sunriseTime, sunsetTime, locationManager.cityName, weatherIcon, weatherDescription)
                        case .failure(let error):
                            print("Nie udało się pobrać danych pogodowych: \(error.localizedDescription)")
                            completion("--:--", "--:--", locationManager.cityName, "01d", "Brak danych")
                        }
                    }
                } else {
                    print("Nazwa miasta jest nieznana, nie można pobrać danych pogodowych.")
                    completion("--:--", "--:--", "Nieznane", "01d", "Brak danych")
                }
                
            case .failure(let error):
                print("Nie udało się pobrać lokalizacji: \(error.localizedDescription)")
                completion("--:--", "--:--", "Nieznane", "01d", "Brak danych")
            }
        }
    }
}

// MARK: - SunriseSunsetWidget View
/// Widok dla widgetu, wyświetlający nazwę miasta, czas wschodu i zachodu słońca oraz inne dane pogodowe.
struct SunriseSunsetWidgetEntryView: View {
    var entry: SunriseSunsetWidgetEntry
    
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
                    VStack {
                        Text("Sunrise")
                            .font(.caption)
                        Text(entry.sunriseTime)
                            .font(.title2.bold())
                            .foregroundColor(.orange)
                    }
                    VStack {
                        Text("Sunset")
                            .font(.caption)
                        Text(entry.sunsetTime)
                            .font(.title2.bold())
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 10)
                .background(Color.orange.opacity(0.2))
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
                HStack {
                    IconConvert(for: entry.weatherIcon, useWeatherColors: false)
                        .scaleEffect(1.2)
                }
            }
            
            Spacer()
            
            HStack {
                VStack {
                    Text("Sunrise")
                        .font(.caption)
                    Text(entry.sunriseTime)
                        .font(.callout.bold())
                        .foregroundColor(.orange)
                }
                Spacer()
                VStack {
                    Text("Sunset")
                        .font(.caption)
                    Text(entry.sunsetTime)
                        .font(.callout.bold())
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 15)
            .background(Color.orange.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - SunriseSunsetWidget Configuration
/// Konfiguracja widgetu, w tym jego wyświetlana nazwa i opis.
struct SunriseSunsetWidget: Widget {
    let kind: String = "SunriseSunsetWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SunriseSunsetWidgetProvider()) { entry in
            SunriseSunsetWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Widget wschodu i zachodu słońca")
        .description("Wyświetla czas wschodu i zachodu słońca na podstawie lokalizacji.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
/// Podgląd widgetu w trybie edycji.
#Preview(as: .systemSmall) {
    SunriseSunsetWidget()
} timeline: {
    SunriseSunsetWidgetEntry(date: Date(), sunriseTime: "06:00 AM", sunsetTime: "08:00 PM", cityName: "Warszawa", weatherIcon: "01d", weatherDescription: "Słonecznie")
}

#Preview(as: .systemMedium) {
    SunriseSunsetWidget()
} timeline: {
    SunriseSunsetWidgetEntry(date: Date(), sunriseTime: "06:00 AM", sunsetTime: "08:00 PM", cityName: "Warszawa", weatherIcon: "01d", weatherDescription: "Słonecznie")
}
