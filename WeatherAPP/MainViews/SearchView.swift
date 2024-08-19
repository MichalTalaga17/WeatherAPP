//
//  ContentView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 02/08/2024.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @AppStorage("iconsColorsBasedOnWeather") private var iconsColorsBasedOnWeather: Bool = true
    
    @Query private var cities: [FavouriteCity]
    @State private var cityName: String = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                HStack {
                    TextField("Search for city", text: $cityName)
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(8)
                    
                    NavigationLink(destination: WeatherView(cityName: cityName)) {
                        Text("Go")
                            .padding()
                            .background(cityName.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(cityName.isEmpty)
                }.padding()
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(cities, id: \.self) { city in
                        NavigationLink(destination: WeatherView(cityName: city.name)) {
                            HStack(spacing: 5) {
                                Text(city.name)
                                    .font(.title2)
                                Spacer()
                                HStack {
                                    if let temperature = city.temperature {
                                        Text("\(Int(temperature))°")
                                            .font(.title3)
                                    }
                                    if let icon = city.weatherIcon {
                                        IconConvert(for: icon, useWeatherColors: iconsColorsBasedOnWeather)
                                    }
                                }
                            }
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .padding()
                        .task {
                            await fetchWeatherData(for: city)
                        }
                    }
                }
                Spacer()
            }
        }
    }
    
    func fetchWeatherData(for city: FavouriteCity) async {
        API.shared.fetchCurrentWeatherData(forCity: city.name) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    city.temperature = data.main.temp
                    city.weatherIcon = data.weather.first?.icon
                }
            case .failure(let error):
                // Handle error here if necessary
                print("Failed to fetch weather data for \(city.name): \(error)")
            }
        }
    }
}

#Preview{
    SearchView()
}
