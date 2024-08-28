//
//  Pollution.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 22/08/2024.
//

import SwiftUI

struct PollutionDataView: View {
    let pollutionEntry: PollutionEntry
    
    var body: some View {
        HStack {
            PollutionDataDetail(value: "\(aqiDescription(for: pollutionEntry.main.aqi))", label: "AQI")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.pm2_5))", label: "PM2.5")
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.pm10))", label: "PM10")
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.co))", label: "CO")
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.no))", label: "NO")
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.no2))", label: "NO2")
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.o3))", label: "O3")
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.so2))", label: "SO2")
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.nh3))", label: "NH3")
                }
            }
        }
        .padding()
        .background(.material)
        .cornerRadius(8)
    }
}

struct PollutionDataDetail: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2 .bold())
            Text(label)
                .font(.caption)
        }
        .frame(width: UIScreen.main.bounds.width * 0.15)
    }
}
