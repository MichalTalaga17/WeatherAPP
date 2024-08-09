//
//  ForecastWidget.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 09/08/2024.
//

import WidgetKit
import SwiftUI
import Intents


struct ForecastEntry: TimelineEntry {
    let date: Date
    let forecast: [ForecastItem]
}

struct ForecastItem {
    let time: String
    let temperature: Double
    let iconName: String
}


struct ForecastProvider: TimelineProvider {
    func placeholder(in context: Context) -> ForecastEntry {
        ForecastEntry(date: Date(), forecast: [
            ForecastItem(time: "08:00", temperature: 15.0, iconName: "sun.max"),
            ForecastItem(time: "12:00", temperature: 20.0, iconName: "cloud.sun"),
            ForecastItem(time: "16:00", temperature: 18.0, iconName: "cloud.rain"),
        ])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ForecastEntry) -> ()) {
        let entry = ForecastEntry(date: Date(), forecast: [
            ForecastItem(time: "08:00", temperature: 15.0, iconName: "sun.max"),
            ForecastItem(time: "12:00", temperature: 20.0, iconName: "cloud.sun"),
            ForecastItem(time: "16:00", temperature: 18.0, iconName: "cloud.rain"),
        ])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ForecastEntry>) -> ()) {
        var entries: [ForecastEntry] = []
        let currentDate = Date()
        
        // Create a timeline entry for the next hour
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let entry = ForecastEntry(date: currentDate, forecast: [
            ForecastItem(time: "08:00", temperature: 15.0, iconName: "sun.max"),
            ForecastItem(time: "12:00", temperature: 20.0, iconName: "cloud.sun"),
            ForecastItem(time: "16:00", temperature: 18.0, iconName: "cloud.rain"),
        ])
        entries.append(entry)
        
        // Create the timeline with an update frequency of 1 hour
        let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
        completion(timeline)
    }
}


struct ForecastWidgetEntryView: View {
    var entry: ForecastProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Prognoza pogody")
                .font(.headline)
                .bold()
            
            ForEach(entry.forecast, id: \.time) { item in
                HStack {
                    Image(systemName: item.iconName)
                    Text("\(item.time): \(Int(item.temperature))°C")
                }
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            Color.black.opacity(0.3)
        }
        .cornerRadius(10)
        .foregroundColor(.white)
    }
}


struct WeatherWidgetForecast: Widget {
    let kind: String = "WeatherWidgetForecast"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ForecastProvider()) { entry in
            ForecastWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Prognoza Pogody")
        .description("Wyświetla prognozę pogody na kilka nadchodzących godzin.")
    }
}


