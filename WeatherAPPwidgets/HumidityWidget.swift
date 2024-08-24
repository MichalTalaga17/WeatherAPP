//
//  HumidityWidget.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 24/08/2024.
//

import SwiftUI
import WidgetKit
import CoreLocation

// MARK: - HumidityWidget Entry
/// Struktura przechowująca dane dla widgetu.
struct HumidityWidgetEntry: TimelineEntry {
    var date: Date
    
    let cityName: String
    let humidity: String
}

// MARK: - HumidityWidget Provider
/// Provider dostarczający dane dla widgetu.
struct HumidityWidgetProvider: TimelineProvider {
    @ObservedObject private var locationManager = LocationManager()
    private let api = API.shared
    
    func placeholder(in context: Context) -> HumidityWidgetEntry {
        HumidityWidgetEntry(date: Date(), cityName: "Nieznane", humidity: "-- %")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (HumidityWidgetEntry) -> Void) {
        fetchHumidityData(completion: completion)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<HumidityWidgetEntry>) -> Void) {
        fetchHumidityData { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    private func fetchHumidityData(completion: @escaping (HumidityWidgetEntry) -> Void) {
        locationManager.requestLocation { result in
            switch result {
            case .success(let location):
                guard locationManager.cityName != "Unknown" else {
                    completion(HumidityWidgetEntry(date: Date(), cityName: "Nieznane", humidity: "-- %"))
                    return
                }
                
                api.fetchCurrentWeatherData(forCity: locationManager.cityName) { result in
                    switch result {
                    case .success(let data):
                        let humidity = "\(data.main.humidity) %"
                        completion(HumidityWidgetEntry(date: Date(), cityName: locationManager.cityName, humidity: humidity))
                    case .failure:
                        completion(HumidityWidgetEntry(date: Date(), cityName: locationManager.cityName, humidity: "-- %"))
                    }
                }
            case .failure:
                completion(HumidityWidgetEntry(date: Date(), cityName: "Nieznane", humidity: "-- %"))
            }
        }
    }
}

// MARK: - HumidityWidget View
/// Widok dla widgetu, wyświetlający nazwę miasta i wilgotność.
struct HumidityWidgetEntryView: View {
    var entry: HumidityWidgetEntry
    
    private var humidityValue: Int {
        Int(entry.humidity.replacingOccurrences(of: " %", with: "")) ?? 0
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.cityName)
                    .font(.headline)
                Spacer()
                VStack(alignment: .leading) {
                    Text("\(humidityValue)")
                        .font(.title.bold())
                        .foregroundColor(.blue)
                    Text("%")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .background(Color.accentColor.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - HumidityWidget Configuration
/// Konfiguracja widgetu, w tym jego wyświetlana nazwa i opis.
struct HumidityWidget: Widget {
    let kind: String = "HumidityWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HumidityWidgetProvider()) { entry in
            HumidityWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Widget wilgotności")
        .description("Wyświetla aktualną wilgotność i nazwę miasta.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Preview
/// Podgląd widgetu w trybie edycji.
#Preview(as: .systemSmall) {
    HumidityWidget()
} timeline: {
    HumidityWidgetEntry(date: Date(), cityName: "Warszawa", humidity: "65 %")
}

