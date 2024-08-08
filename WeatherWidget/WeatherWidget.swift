//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by Michał Talaga on 08/08/2024.
//

import WidgetKit
import SwiftUI
import AppIntents

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct WeatherWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.configuration.firstText)
                .font(.headline)
            Spacer()
            HStack {
                Text(entry.configuration.secondText)
                    .font(.title)
                
                Text(entry.configuration.thirdText)
            }
        }
    }
}

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
                .containerBackground(Color.red.opacity(0.2), for: .widget)
        }
    }
}


#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    // Utwórz instancję ConfigurationAppIntent z parametrami
    let intent = ConfigurationAppIntent()
    intent.firstText = "Zembrzyce"
    intent.secondText = "20"
    intent.thirdText = "Chmury"
    return [
        SimpleEntry(date: .now, configuration: intent)
    ]
}
