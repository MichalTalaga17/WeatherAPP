//
//  SunriseWidget.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 26/08/2024.
//

import WidgetKit
import SwiftUI
import CoreLocation

// MARK: - SunriseEntry
struct SunriseEntry: TimelineEntry {
    var date: Date
    let cityName: String
    let sunriseTime: String
}

// MARK: - SunriseProvider
struct SunriseProvider: TimelineProvider {
    @ObservedObject private var locationManager = LocationManager()
    private let api = API.shared

    func placeholder(in context: Context) -> SunriseEntry {
        SunriseEntry(date: Date(), cityName: "Unknown", sunriseTime: "--:--")
    }

    func getSnapshot(in context: Context, completion: @escaping (SunriseEntry) -> Void) {
        let entry = SunriseEntry(date: Date(), cityName: "Sample City", sunriseTime: "06:30 AM")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SunriseEntry>) -> Void) {
        fetchSunriseData { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }

    private func fetchSunriseData(completion: @escaping (SunriseEntry) -> Void) {
        let currentDate = Date()

        locationManager.requestLocation { result in
            switch result {
            case .success(_):
                guard locationManager.cityName != "Unknown" else {
                    completion(SunriseEntry(date: currentDate, cityName: "Unknown", sunriseTime: "--:--"))
                    return
                }

                api.fetchCurrentWeatherData(forCity: locationManager.cityName) { result in
                    switch result {
                    case .success(let data):
                        let sunriseDate = Date(timeIntervalSince1970: TimeInterval(data.sys.sunrise))
                        let formatter = DateFormatter()
                        formatter.timeStyle = .short
                        formatter.timeZone = TimeZone(secondsFromGMT: data.timezone)
                        let sunriseTime = formatter.string(from: sunriseDate)
                        completion(SunriseEntry(date: currentDate, cityName: locationManager.cityName, sunriseTime: sunriseTime))
                    case .failure:
                        completion(SunriseEntry(date: currentDate, cityName: locationManager.cityName, sunriseTime: "--:--"))
                    }
                }
            case .failure:
                completion(SunriseEntry(date: currentDate, cityName: "Unknown", sunriseTime: "--:--"))
            }
        }
    }
}

// MARK: - SunriseEntryView
struct SunriseEntryView: View {
    var entry: SunriseProvider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.cityName)
                .font(.headline)
            Text("Sunrise")
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(entry.sunriseTime)
                .font(.title2.bold())
                .foregroundStyle(Color.orange)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(Color.orange.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
    }
}

// MARK: - SunriseWidget
struct SunriseWidget: Widget {
    let kind: String = "SunriseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SunriseProvider()) { entry in
            SunriseEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Sunrise Widget")
        .description("Displays the time of sunrise for your current location.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    SunriseWidget()
} timeline: {
    SunriseEntry(date: Date(), cityName: "Warszawa", sunriseTime: "06:30 AM")
}

