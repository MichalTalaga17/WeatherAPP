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
        VStack(alignment: .center, spacing: 10) {
            HStack {
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
            HStack {
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
