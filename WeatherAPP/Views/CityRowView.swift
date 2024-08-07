//
//  CityRowView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 07/08/2024.
//

import SwiftUI
import SwiftData
import Foundation

struct CityRowView: View {
    @Environment(\.modelContext) private var modelContext
    @State var city: City
    
    var body: some View {
        NavigationLink(destination: LocationWeatherView(cityName: city.name, favourite: true)) {
            HStack {
                Text(city.name)
                Spacer()
                if let temperature = city.temperature {
                    Text("\(String(format: "%.1f", temperature))°C")
                }
                if let icon = city.weatherIcon {
                    Image(systemName: icon)
                }
            }
        }
    }
}
