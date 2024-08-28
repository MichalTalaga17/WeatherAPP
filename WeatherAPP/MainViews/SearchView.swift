//
//  ContentView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 02/08/2024.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    // AppStorage Properties
    @AppStorage("iconsColorsBasedOnWeather") private var iconsColorsBasedOnWeather: Bool = true
    @AppStorage("mainIcon") private var mainIcon: String = ""
    @AppStorage("backgroundStyle") private var backgroundStyle: BackgroundStyle = .gradient
    
    // Query Property for Favorite Cities
    @Query private var cities: [FavouriteCity]
    
    // State for the Search TextField
    @State private var cityName: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background View
                if backgroundStyle == .gradient {
                    backgroundView(for: mainIcon)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Color.clear
                        .edgesIgnoringSafeArea(.all)
                }
                
                VStack(alignment: .leading) {
                    searchFieldSection
                    citiesListSection
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    // MARK: - Sections
    
    private var searchFieldSection: some View {
        HStack {
            TextField("Search for city", text: $cityName)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            
            NavigationLink(destination: WeatherView(cityName: cityName)) {
                Text("Go")
                    .padding()
                    .background(cityName.isEmpty ? Color.black.opacity(0.4) : Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(cityName.isEmpty)
        }
        .padding(.vertical, 40)
    }
    
    private var citiesListSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(cities, id: \.self) { city in
                NavigationLink(destination: WeatherView(cityName: city.name)) {
                    cityRow(for: city)
                }
                .background(.material)
                .cornerRadius(15)
                .task {
                    await fetchWeatherData(for: city)
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func cityRow(for city: FavouriteCity) -> some View {
        HStack(spacing: 5) {
            Text(city.name)
                .font(.title2)
                .padding()
            Spacer()
            HStack {
                if let temperature = city.temperature {
                    Text("\(Int(temperature))°")
                        .font(.title2.bold())
                }
                if let icon = city.weatherIcon {
                    IconConvert(for: icon, useWeatherColors: iconsColorsBasedOnWeather)
                        .padding()
                }
            }
        }
    }
    
    private func backgroundView(for icon: String) -> some View {
        gradientBackground(for: icon)
    }
    
    // MARK: - Networking
    
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

// MARK: - Preview

#Preview {
    SearchView()
}
