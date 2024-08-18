//
//  AirPollutionView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 18/08/2024.
//

import SwiftUI

struct AirPollutionView: View {
    let pollution: PollutionData

    var body: some View {
        ScrollView(.horizontal) {
            if let pollutionEntry = pollution.list.first {
                HStack {
                    VStack {
                        Text("\(Int(pollutionEntry.components.pm2_5))")
                        Text("PM2.5")
                    }
                    VStack {
                        Text("\(Int(pollutionEntry.components.pm10))")
                        Text("PM10")
                    }
                    VStack {
                        Text("\(aqiDescription(for: pollutionEntry.main.aqi))")
                        Text("AQI")
                    }
                    VStack {
                        Text("\(Int(pollutionEntry.components.co))")
                        Text("CO")
                    }
                    VStack {
                        Text("\(Int(pollutionEntry.components.no2))")
                        Text("NO2")
                    }
                }
            }
        }
        .padding()
    }
}
