//
//  AirQualitySmallWidget.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 25/08/2024.
//

import Foundation
import SwiftUI
import WidgetKit

// MARK: - AirQualitySmallWidget Entry
struct AirQualitySmallWidgetEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let aqi: Int
    let aqiDescription: String
    let pm25: Double?
    let pm10: Double?
    let displayOption: DisplayOption

    enum DisplayOption: String {
        case basic
        case detailed

        var displayName: String {
            switch self {
            case .basic:
                return "AQI"
            case .detailed:
                return "Detailed AQI"
            }
        }
    }
}
struct AirQualitySmallWidgetProvider: TimelineProvider {
    @AppStorage("displayOption") private var displayOption: AirQualitySmallWidgetEntry.DisplayOption = .basic
    private let api = API.shared
    
    func placeholder(in context: Context) -> AirQualitySmallWidgetEntry {
        AirQualitySmallWidgetEntry(
            date: Date(),
            cityName: "Unknown",
            aqi: 0,
            aqiDescription: "Unknown",
            pm25: nil,
            pm10: nil,
            displayOption: displayOption
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AirQualitySmallWidgetEntry) -> Void) {
        fetchAirQuality { entry in
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AirQualitySmallWidgetEntry>) -> Void) {
        fetchAirQuality { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    private func fetchAirQuality(completion: @escaping (AirQualitySmallWidgetEntry) -> Void) {
        // Replace "Your City" with a valid city name or fetch it from a stored setting
        let city = "Your City"
        
        api.fetchAirPollutionData(forCity: city) { result in
            switch result {
            case .success(let pollutionData):
                let latestEntry = pollutionData.list.first ?? PollutionEntry(main: MainPollution(aqi: 0), components: PollutionComponents(co: 0, no: 0, no2: 0, o3: 0, so2: 0, pm2_5: 0, pm10: 0, nh3: 0))
                let entry = AirQualitySmallWidgetEntry(
                    date: Date(),
                    cityName: city,
                    aqi: latestEntry.main.aqi,
                    aqiDescription: aqiDescription(for: latestEntry.main.aqi),
                    pm25: displayOption == .detailed ? latestEntry.components.pm2_5 : nil,
                    pm10: displayOption == .detailed ? latestEntry.components.pm10 : nil,
                    displayOption: displayOption
                )
                completion(entry)
                
            case .failure(let error):
                print("Failed to fetch air quality data: \(error.localizedDescription)")
                let entry = AirQualitySmallWidgetEntry(
                    date: Date(),
                    cityName: "Unknown",
                    aqi: 0,
                    aqiDescription: "Unknown",
                    pm25: nil,
                    pm10: nil,
                    displayOption: displayOption
                )
                completion(entry)
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
struct AirQualitySmallWidgetEntryView: View {
    var entry: AirQualitySmallWidgetEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.cityName)
                .font(.headline)
            Text("AQI: \(entry.aqi)")
                .font(.title2)
                .foregroundColor(.blue)
            Text(entry.aqiDescription)
                .font(.subheadline)
                .padding(.vertical, 5)
                .background(Color.accentColor.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            if entry.displayOption == .detailed, let pm25 = entry.pm25, let pm10 = entry.pm10 {
                VStack(alignment: .leading) {
                    Text("PM2.5: \(pm25, specifier: "%.1f") µg/m³")
                        .font(.footnote)
                    Text("PM10: \(pm10, specifier: "%.1f") µg/m³")
                        .font(.footnote)
                }
                .padding(.top, 5)
            }
        }
    }
}
struct AirQualitySmallWidget: Widget {
    let kind: String = "AirQualitySmallWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AirQualitySmallWidgetProvider()) { entry in
            AirQualitySmallWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Air Quality Widget")
        .description("Displays air quality information for a selected city.")
        .supportedFamilies([.systemSmall])
    }
}
#Preview(as: .systemSmall) {
    AirQualitySmallWidget()
} timeline: {
    AirQualitySmallWidgetEntry(date: Date(), cityName: "Warszawa", aqi: 2, aqiDescription: "Fair", pm25: 12.5, pm10: 20.0, displayOption: .detailed)
}
