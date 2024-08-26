//
//  AirQualityWidget.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 25/08/2024.
//

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

// MARK: - AirQualityWidget Provider
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

// MARK: - AirQualityWidget Entry View
struct AirQualityWidgetEntryView: View {
    var entry: AirQualityWidgetEntry
    
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
        return HStack(alignment: .top) {
            VStack(alignment: .leading){
                Text(entry.cityName)
                    .font(.headline)
                Text("Air Quality")
                    .font(.caption)
                Spacer()
                Text("\(entry.aqiDescription)")
                    .font(.title.bold())
                    .foregroundStyle(Color.blue)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Spacer()
        }
        
    }
    
    var mediumView: some View {
        VStack(alignment: .leading) {
            HStack{
                VStack{
                    Text(entry.cityName)
                        .font(.headline)
                    Text("Air Quality")
                        .font(.caption)
                }
                Spacer()
                Text("\(entry.aqiDescription)")
                    .font(.title)
            }
            Spacer()
            HStack(alignment: .center) {
                VStack(spacing: 2){
                    Text("\(String(format: "%.0f", entry.components.co))")
                        .font(.callout .bold())
                    Text("CO")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 2){
                    Text("\(String(format: "%.0f", entry.components.no))")
                        .font(.callout .bold())
                    Text("NO")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 2){
                    Text("\(String(format: "%.0f", entry.components.no2))")
                        .font(.callout .bold())
                    Text("NO₂")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 2){
                    Text("\(String(format: "%.0f", entry.components.o3))")
                        .font(.callout .bold())
                    Text("O₃")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 2){
                    Text("\(String(format: "%.0f", entry.components.so2))")
                        .font(.callout .bold())
                    Text("SO₂")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 2){
                    Text("\(String(format: "%.0f", entry.components.pm2_5))")
                        .font(.callout .bold())
                    Text("PM25")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 2){
                    Text("\(String(format: "%.0f", entry.components.pm10))")
                        .font(.callout .bold())
                    Text("PM10")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 2){
                    Text("\(String(format: "%.0f", entry.components.nh3))")
                        .font(.callout .bold())
                    Text("NH₃")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
            }
            .foregroundStyle(Color.blue)
            .padding(.vertical, 5)
            .background(Color.blue.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .font(.footnote)
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
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
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
