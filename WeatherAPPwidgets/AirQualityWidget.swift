//
//  AirQualityWidget.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 25/08/2024.
//

import Foundation
import SwiftUI
import WidgetKit

// MARK: - AirQualityWidget Entry
struct AirQualityWidgetEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let aqi: Int
    let aqiDescription: String
    let components: PollutionComponents
}

struct AirQualityWidgetProvider: TimelineProvider {
    @ObservedObject private var locationManager = LocationManager()
    private let api = API.shared
    
    func placeholder(in context: Context) -> AirQualityWidgetEntry {
        AirQualityWidgetEntry(
            date: Date(),
            cityName: "Unknown",
            aqi: 1,
            aqiDescription: "Good",
            components: PollutionComponents(co: 0, no: 0, no2: 0, o3: 0, so2: 0, pm2_5: 0, pm10: 0, nh3: 0)
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AirQualityWidgetEntry) -> Void) {
        fetchAirQuality { entry in
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AirQualityWidgetEntry>) -> Void) {
        fetchAirQuality { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    private func fetchAirQuality(completion: @escaping (AirQualityWidgetEntry) -> Void) {
        locationManager.requestLocation { result in
            switch result {
            case .success(let location):
                api.fetchAirPollutionData(forCity: locationManager.cityName) { result in
                    switch result {
                    case .success(let data):
                        let entry = AirQualityWidgetEntry(
                            date: Date(),
                            cityName: locationManager.cityName,
                            aqi: data.list.first?.main.aqi ?? 1,
                            aqiDescription: aqiDescription(for: data.list.first?.main.aqi ?? 1),
                            components: data.list.first?.components ?? PollutionComponents(co: 0, no: 0, no2: 0, o3: 0, so2: 0, pm2_5: 0, pm10: 0, nh3: 0)
                        )
                        completion(entry)
                    case .failure(let error):
                        print("Failed to fetch air quality data: \(error.localizedDescription)")
                        completion(AirQualityWidgetEntry(
                            date: Date(),
                            cityName: "Unknown",
                            aqi: 1,
                            aqiDescription: "Unknown",
                            components: PollutionComponents(co: 0, no: 0, no2: 0, o3: 0, so2: 0, pm2_5: 0, pm10: 0, nh3: 0)
                        ))
                    }
                }
            case .failure(let error):
                print("Failed to get location: \(error.localizedDescription)")
                completion(AirQualityWidgetEntry(
                    date: Date(),
                    cityName: "Unknown",
                    aqi: 1,
                    aqiDescription: "Unknown",
                    components: PollutionComponents(co: 0, no: 0, no2: 0, o3: 0, so2: 0, pm2_5: 0, pm10: 0, nh3: 0)
                ))
            }
        }
    }
    func aqiDescription(for aqi: Int) -> String {
        switch aqi {
        case 1:
            return "Good"
        case 2:
            return "Fair"
        case 3:
            return "Moderate"
        case 4:
            return "Poor"
        case 5:
            return "Very Poor"
        default:
            return "Unknown"
        }
    }
}


struct AirQualityWidgetEntryView: View {
    var entry: AirQualityWidgetEntry
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.cityName)
                .font(.headline)
            
            Text("Air Quality: \(entry.aqiDescription)")
                .font(.title2)
                .padding(.bottom, 5)
            
            if widgetFamily == .systemMedium {
                HStack(alignment: .center) {
                    Text("CO: \(String(format: "%.1f", entry.components.co)) µg/m³")
                    Text("NO: \(String(format: "%.1f", entry.components.no)) µg/m³")
                    Text("NO₂: \(String(format: "%.1f", entry.components.no2)) µg/m³")
                    Text("O₃: \(String(format: "%.1f", entry.components.o3)) µg/m³")
                    Text("SO₂: \(String(format: "%.1f", entry.components.so2)) µg/m³")
                    Text("PM₂.₅: \(String(format: "%.1f", entry.components.pm2_5)) µg/m³")
                    Text("PM₁₀: \(String(format: "%.1f", entry.components.pm10)) µg/m³")
                    Text("NH₃: \(String(format: "%.1f", entry.components.nh3)) µg/m³")
                }
                .font(.footnote)
                .padding(.top, 10)
            }
        }
    }
}

// MARK: - AirQualityWidget Configuration
struct AirQualityWidget: Widget {
    let kind: String = "AirQualityWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AirQualityWidgetProvider()) { entry in
            AirQualityWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Air Quality Widget")
        .description("Displays the air quality information for your location.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemMedium) {
    AirQualityWidget()
} timeline: {
    AirQualityWidgetEntry(
        date: Date(),
        cityName: "Warsaw",
        aqi: 2,
        aqiDescription: "Fair",
        components: PollutionComponents(co: 0.5, no: 0.1, no2: 0.2, o3: 0.3, so2: 0.4, pm2_5: 10, pm10: 20, nh3: 0.05)
    )
}
