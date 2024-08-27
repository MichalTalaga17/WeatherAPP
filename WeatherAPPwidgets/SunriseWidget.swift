//
//  SunTimesWidget.swift
//  WeatherAPPwidgets
//
//  Created by Michał Talaga on 26/08/2024.
//

import SwiftUI
import WidgetKit
import CoreLocation

// MARK: - SunTimesEntry
/// Struktura przechowująca dane dla widżetu.
struct SunTimesEntry: TimelineEntry {
    let date: Date
    let sunriseTime: String
    let sunsetTime: String
    let locationName: String
}

// MARK: - SunTimesProvider
/// Provider dostarczający dane dla widżetu.
struct SunTimesProvider: TimelineProvider {
    @ObservedObject private var locationManager = LocationManager()
    private let api = API.shared
    
    /// Funkcja zwracająca dane przykładowe dla widżetu w trybie podglądu.
    func placeholder(in context: Context) -> SunTimesEntry {
        SunTimesEntry(
            date: Date(),
            sunriseTime: "--:--",
            sunsetTime: "--:--",
            locationName: "Nieznane"
        )
    }
    
    /// Funkcja zwracająca dane dla widżetu w trybie podglądu.
    func getSnapshot(in context: Context, completion: @escaping (SunTimesEntry) -> Void) {
        fetchSunTimes { sunriseTime, sunsetTime, locationName in
            let entry = SunTimesEntry(
                date: Date(),
                sunriseTime: sunriseTime,
                sunsetTime: sunsetTime,
                locationName: locationName
            )
            completion(entry)
        }
    }
    
    /// Funkcja zwracająca dane dla harmonogramu widżetu.
    func getTimeline(in context: Context, completion: @escaping (Timeline<SunTimesEntry>) -> Void) {
        fetchSunTimes { sunriseTime, sunsetTime, locationName in
            let entry = SunTimesEntry(
                date: Date(),
                sunriseTime: sunriseTime,
                sunsetTime: sunsetTime,
                locationName: locationName
            )
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    /// Funkcja pobierająca czas wschodu i zachodu słońca.
    private func fetchSunTimes(completion: @escaping (String, String, String) -> Void) {
        locationManager.requestLocation { result in
            switch result {
            case .success(let location):
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                
                api.fetchSunTimes(lat: latitude, lon: longitude) { result in
                    switch result {
                    case .success(let data):
                        let formatter = DateFormatter()
                        formatter.timeStyle = .short
                        formatter.timeZone = TimeZone(secondsFromGMT: data.timezone)
                        
                        let sunriseTime = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(data.sunrise)))
                        let sunsetTime = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(data.sunset)))
                        let locationName = locationManager.cityName != "Unknown" ? locationManager.cityName : "Nieznane"
                        
                        completion(sunriseTime, sunsetTime, locationName)
                    case .failure(let error):
                        print("Błąd pobierania danych: \(error.localizedDescription)")
                        completion("--:--", "--:--", "Nieznane")
                    }
                }
            case .failure(let error):
                print("Błąd lokalizacji: \(error.localizedDescription)")
                completion("--:--", "--:--", "Nieznane")
            }
        }
    }
}

// MARK: - SunTimesEntryView
/// Widok dla widżetu, wyświetlający czasy wschodu i zachodu słońca oraz nazwę lokalizacji.
struct SunTimesEntryView: View {
    var entry: SunTimesProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.locationName)
                .font(.headline)
                .padding(.bottom, 4)
            HStack {
                VStack(alignment: .leading) {
                    Text("Sunrise")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(entry.sunriseTime)
                        .font(.title2.bold())
                        .foregroundColor(.orange)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Sunset")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(entry.sunsetTime)
                        .font(.title2.bold())
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground).opacity(0.7))
        .cornerRadius(10)
    }
}

// MARK: - SunTimesWidget
/// Konfiguracja widżetu, w tym jego wyświetlana nazwa i opis.
struct SunTimesWidget: Widget {
    let kind: String = "SunTimesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SunTimesProvider()) { entry in
            SunTimesEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Sun Times Widget")
        .description("Displays the sunrise and sunset times for your location.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
/// Podgląd widżetu w trybie edycji.
#Preview(as: .systemSmall) {
    SunTimesWidget()
} timeline: {
    SunTimesEntry(date: Date(), sunriseTime: "06:00 AM", sunsetTime: "08:00 PM", locationName: "Warszawa")
}

#Preview(as: .systemMedium) {
    SunTimesWidget()
} timeline: {
    SunTimesEntry(date: Date(), sunriseTime: "06:00 AM", sunsetTime: "08:00 PM", locationName: "Warszawa")
}

