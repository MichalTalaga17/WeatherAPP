//
//  Views.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 10/08/2024.
//

import Foundation
import SwiftUI


// MARK: - Widok dla widgetu prognozy

struct ForecastWidgetEntryView: View {
    var entry: ForecastProvider.Entry
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack {
                Text(entry.cityName)
                    .font(.callout)
                    .bold()
            }
            HStack(alignment: .top) {
                ForEach(entry.forecast, id: \.time) { item in
                    VStack {
                        Text(formatDate(timestamp: item.time, formatType: .timeOnly, timeZone: entry.timeZone))
                            .font(.footnote)
                        Spacer()
                        Image(systemName: item.iconName)
                            .font(.title)
                            .padding(.vertical, 5)
                        Spacer()
                        Text(kelvinToCelsius(item.temperature))
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            Color.black.opacity(0.3)
        }
        .cornerRadius(10)
        .foregroundColor(.white)
    }
    
    
    
}

struct WeatherWidgetEntryView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            HStack (alignment: .center) {
                Spacer()
                Image(systemName: entry.icon)
                    .font(.largeTitle)
                Spacer()
            }
            Text("\(entry.city) \(Int(entry.temperature))°")
                .font(.subheadline)
            
        }
        .padding(.vertical)
        .cornerRadius(8)
        .foregroundColor(.white)
        .containerBackground(for: .widget) {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            Color.black.opacity(0.3)
        }
    }
}

struct WeatherWidgetMediumEntryView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(entry.city)
                    .font(.headline)
                    .bold()
                Spacer()
                Text("\(Int(entry.temperature))°C")
                    .font(.largeTitle)
            }
            Spacer()
            HStack {
                VStack(alignment: .leading ,spacing: 15) {
                    WeatherFeatureView(iconName: "thermometer", text: "\(Int(entry.feelsLike))°C")
                    WeatherFeatureView(iconName: "drop.fill", text: "\(entry.humidity)%")
                }
                Spacer()
                
                VStack(alignment: .leading ,spacing: 15) {
                    WeatherFeatureView(iconName: "wind", text: "\(Int(entry.windSpeed)) m/s")
                    WeatherFeatureView(iconName: "cloud", text: "\(entry.cloudiness)%")
                }
                Spacer()
                
                VStack(alignment: .leading ,spacing: 15) {
                    WeatherFeatureView(iconName: "eye", text: "\(entry.visibility / 1000) km")
                    WeatherFeatureView(iconName: "gauge", text: "\(entry.pressure) hPa")
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

// MARK: - Widok dla funkcji pogodowych

struct WeatherFeatureView: View {
    let iconName: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
            Text(text)
        }
    }
}


// MARK: - Średni widok dla widoku zanieczyszczenia

struct PollutionMediumWidgetView: View {
    let entry: PollutionEntry2
    
    var body: some View {
        VStack(alignment: .center) {
            Text(entry.cityName)
                .font(.headline)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity)
            Spacer()
            HStack(alignment: .center, spacing: 0) {
                pollutionComponentView(name: "AQI", value: Double(entry.pollution.list.first?.main.aqi ?? 0))
                pollutionComponentView(name: "PM2.5", value: entry.pollution.list.first?.components.pm2_5 ?? 0)
                pollutionComponentView(name: "PM10", value: entry.pollution.list.first?.components.pm10 ?? 0)
                pollutionComponentView(name: "O₃", value: entry.pollution.list.first?.components.o3 ?? 0)
                pollutionComponentView(name: "NO₂", value: entry.pollution.list.first?.components.no2 ?? 0)
                pollutionComponentView(name: "SO₂", value: entry.pollution.list.first?.components.so2 ?? 0)
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .containerBackground(for: .widget) {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            Color.black.opacity(0.3)
        }
        .cornerRadius(10)
        .foregroundColor(.white)
    }
    
    
    
    private func pollutionComponentView(name: String, value: Double) -> some View {
        VStack {
            Text(String(format: "%.0f", value))
                .font(.title)
                .padding(.bottom, 5)
            Text(name)
                .font(.caption2)
                .foregroundColor(Color.white)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PollutionSmallWidgetView: View {
    let entry: PollutionEntry2
    
    var body: some View {
        VStack(alignment: .center) {
            
            VStack {
                Text(String(format: "%.0f", Double(entry.pollution.list.first?.main.aqi ?? 0)))
                    .frame(maxWidth: .infinity)
                    .font(.title)
                    .padding(.bottom, 5)
                Text("AQI")
                    .frame(maxWidth: .infinity)
                    .font(.headline)
                    .padding(.bottom, 5)
            }
            
            Text(entry.cityName)
                .foregroundColor(Color.white)
        }
        .containerBackground(for: .widget) {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            Color.black.opacity(0.3)
        }
        .cornerRadius(10)
        .foregroundColor(.white)
    }
}

