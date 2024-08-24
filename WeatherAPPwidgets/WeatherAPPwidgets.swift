//
//  WeatherAPPwidgets.swift
//  WeatherAPPwidgets
//
//  Created by Michał Talaga on 22/08/2024.
//

import WidgetKit
import SwiftUI
import CoreLocation

// struct Provider: AppIntentTimelineProvider {
//     func placeholder(in context: Context) -> SimpleEntry {
//         SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
//     }

//     func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
//         SimpleEntry(date: Date(), configuration: configuration)
//     }
    
//     func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
//         var entries: [SimpleEntry] = []

//         // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//         let currentDate = Date()
//         for hourOffset in 0 ..< 5 {
//             let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//             let entry = SimpleEntry(date: entryDate, configuration: configuration)
//             entries.append(entry)
//         }

//         return Timeline(entries: entries, policy: .atEnd)
//     }
// }

// struct LocationProvider: TimelineProvider {
//     @ObservedObject var locationManager = LocationManager()
    
//     func placeholder(in context: Context) -> SimpleLocationEntry {
//         SimpleLocationEntry(date: Date(), cityName: "London")
//     }

//     func getSnapshot(in context: Context, completion: @escaping (SimpleLocationEntry) -> Void) {
//         let entry = SimpleLocationEntry(date: Date(), cityName: locationManager.cityName)
//         completion(entry)
//     }

//     func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleLocationEntry>) -> Void) {
//         var entries: [SimpleLocationEntry] = []
//         let currentDate = Date()
        
//         // Pobierz aktualną lokalizację
//         locationManager.requestLocation { result in
//             switch result {
//             case .success(let location):
//                 locationManager.fetchCityName(from: location)
//                 let entry = SimpleLocationEntry(date: currentDate, cityName: locationManager.cityName)
//                 entries.append(entry)
//             case .failure(let error):
//                 print("Failed to get location: \(error.localizedDescription)")
//                 let entry = SimpleLocationEntry(date: currentDate, cityName: "Unknown")
//                 entries.append(entry)
//             }
            
//             let timeline = Timeline(entries: entries, policy: .atEnd)
//             completion(timeline)
//         }
//     }
// }

// struct SimpleEntry: TimelineEntry {
//     let date: Date
//     let configuration: ConfigurationAppIntent
// }
// struct SimpleLocationEntry: TimelineEntry {
//     let date: Date
//     let cityName: String
// }


// struct WeatherAPPwidgetsEntryView : View {
//     var entry: Provider.Entry

//     var body: some View {
//         VStack {
//             Text("Time:")
//             Text(entry.date, style: .time)

//             Text("Favorite Emoji:")
//             Text(entry.configuration.choosenCity)
//         }
//     }
// }

// struct LocationWidgetEntryView : View {
//     var entry: LocationProvider.Entry

//     var body: some View {
//         VStack {
//             Text("Your Location:")
//             Text(entry.cityName)
//                 .font(.title)
//                 .fontWeight(.bold)
//                 .padding(.top, 5)
//             Text("Updated:")
//             Text(entry.date, style: .time)
//         }
//         .padding()
//     }
// }


// struct WeatherAPPwidgets: Widget {
//     let kind: String = "WeatherAPPwidgets"

//     var body: some WidgetConfiguration {
//         AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
//             WeatherAPPwidgetsEntryView(entry: entry)
//                 .containerBackground(.fill.tertiary, for: .widget)
//         }
//     }
// }

// extension ConfigurationAppIntent {
//     fileprivate static var smiley: ConfigurationAppIntent {
//         let intent = ConfigurationAppIntent()
//         intent.choosenCity = "Warszawa"
//         return intent
//     }
    
//     fileprivate static var starEyes: ConfigurationAppIntent {
//         let intent = ConfigurationAppIntent()
//         intent.choosenCity = "Nowy Jork"
//         return intent
//     }
// }

// Konfiguracja nowego widgetu
// struct LocationWidget: Widget {
//     let kind: String = "LocationWidget"

//     var body: some WidgetConfiguration {
//         StaticConfiguration(kind: kind, provider: LocationProvider()) { entry in
//             LocationWidgetEntryView(entry: entry)
//                 .containerBackground(.fill.tertiary, for: .widget)
//         }
//         .configurationDisplayName("Current Location Widget")
//         .description("Displays the current city name based on your location.")
//         .supportedFamilies([.systemSmall, .systemMedium])
//     }
// }


