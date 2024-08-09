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
    let timeZone: TimeZone
    let cityName: String
}

struct ForecastItem {
    let time: Int
    let temperature: Double
    let iconName: String
}


struct ForecastProvider: TimelineProvider {
    func placeholder(in context: Context) -> ForecastEntry {
        ForecastEntry(date: Date(), forecast: [
            ForecastItem(time: 1691572800, temperature: 15.0, iconName: "sun.max"),
            ForecastItem(time: 1691587200, temperature: 20.0, iconName: "cloud.sun"),
            ForecastItem(time: 1691601600, temperature: 18.0, iconName: "cloud.rain"),
            ForecastItem(time: 1691616000, temperature: 16.0, iconName: "cloud.moon")
        ], timeZone: TimeZone.current, cityName: "Miasto")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ForecastEntry) -> ()) {
        fetchForecastData { result in
            switch result {
            case .success(let (forecast, timeZone, cityName)):
                let entry = ForecastEntry(date: Date(), forecast: forecast, timeZone: timeZone, cityName: cityName)
                completion(entry)
            case .failure:
                let entry = ForecastEntry(date: Date(), forecast: [], timeZone: TimeZone.current, cityName: "Nieznane")
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ForecastEntry>) -> ()) {
        fetchForecastData { result in
            switch result {
            case .success(let (forecast, timeZone, cityName)):
                let entry = ForecastEntry(date: Date(), forecast: forecast, timeZone: timeZone, cityName: cityName)
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            case .failure:
                let entry = ForecastEntry(date: Date(), forecast: [], timeZone: TimeZone.current, cityName: "Nieznane")
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            }
        }
    }
    
    private func fetchForecastData(completion: @escaping (Result<([ForecastItem], TimeZone, String), Error>) -> Void) {
        if let userDefaults = UserDefaults(suiteName: "group.me.michaltalaga.WeatherAPP") {
            let city = userDefaults.string(forKey: "City") ?? "Nieznane"
            API.shared.fetchForecastData(forCity: city) { result in
                switch result {
                case .success(let data):
                    let forecastItems = data.list.prefix(6).map { item in
                        ForecastItem(
                            time: Int(item.dt),
                            temperature: item.main.temp,
                            iconName: iconName(for: item.weather.first?.icon ?? "defaultIcon")
                        )
                    }
                    let timeZone = TimeZone(secondsFromGMT: data.city.timezone) ?? TimeZone.current
                    completion(.success((forecastItems, timeZone, city)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func iconName(for icon: String) -> String {
        return iconMap[icon] ?? "questionmark"
    }
}


struct ForecastWidgetEntryView: View {
    var entry: ForecastProvider.Entry
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack{
                Text(entry.cityName)
                    .font(.callout)
                    .bold()
            }
            Spacer()
            HStack(alignment: .top) {
                ForEach(entry.forecast, id: \.time) { item in
                    VStack {
                        Text(formatDate(timestamp: item.time, formatType: .timeOnly, timeZone: entry.timeZone))
                            .font(.footnote)
                            .frame(maxHeight: .infinity)
                        Image(systemName: item.iconName)
                            .font(.title)
                            .padding(.vertical, 5)
                            .frame(maxHeight: .infinity)
                        Text(kelvinToCelsius(item.temperature))
                            .font(.caption2)
                            .frame(maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical)
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

