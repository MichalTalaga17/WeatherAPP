//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by Michał Talaga on 08/08/2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), city: "Twoje Miasto", temperature: 20, icon: "cloud.sun")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        // Przykładowe dane do podglądu
        let entry = SimpleEntry(date: Date(), city: "Warszawa", temperature: 15, icon: "cloud.rain")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        // Przykładowe dane do harmonogramu
        let entries: [SimpleEntry] = [
            SimpleEntry(date: Date(), city: "Kraków", temperature: 18, icon: "sun.max")
        ]
        // Ustawienie polityki odświeżania widgetu
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let city: String
    let temperature: Double
    let icon: String
}

extension View {
    func widgetBackground(backgroundView: some View) -> some View {
        if #available(watchOS 10.0, iOSApplicationExtension 17.0, iOS 17.0, macOSApplicationExtension 14.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

struct WidgetView: View {
    let entry: SimpleEntry

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text(entry.city)
                    .font(.headline)
                Text("\(entry.temperature, specifier: "%.1f")°C")
                    .font(.headline)
                Image(systemName: entry.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
            .padding()
            .cornerRadius(8)
            .frame(height: 160)
            .widgetBackground(backgroundView: Color.clear)
            Spacer()
        }
        .background(LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.blue.opacity(0.3)]),
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        ))
    }
}
extension WidgetConfiguration {
    func disableContentMarginsIfNeeded() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}



struct SimpleWeatherWidget: Widget {
    let kind: String = "SimpleWeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetView(entry: entry)
        }
        .disableContentMarginsIfNeeded()
        .configurationDisplayName("Prosta Pogoda")
        .description("Szybki podgląd temperatury i pogody")
    }
}

#Preview(as: .systemSmall) {
    SimpleWeatherWidget()
}timeline: {
    SimpleEntry(date: Date(), city: "Warszawa", temperature: 20, icon: "cloud.sun")
}
