//
//  MainView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import SwiftUI
import CoreLocation
import SwiftData

struct MainView: View {
    // MARK: - Properties
    @AppStorage("airQuality") private var airQuality: Bool = true
    @AppStorage("iconsColorsBasedOnWeather") private var iconsColorsBasedOnWeather: Bool = true
    @AppStorage("backgroundStyle") private var backgroundStyle: BackgroundStyle = .gradient
    @AppStorage("mainIcon") private var mainIcon: String = ""
    @AppStorage("defaultCity") private var defaultCity: String = "Your location"
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var locationManager = LocationManager()
    
    @Query private var cities: [FavouriteCity]
    
    @State private var currentWeather: CurrentData?
    @State private var forecast: ForecastData?
    @State private var pollution: PollutionData?
    @State private var errorMessage: String?
    
    @State private var cityName: String?
    @State private var isFavourite: Bool = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                if backgroundStyle == .gradient {
                    gradientBackground(for: currentWeather?.weather.first?.icon ?? "01d")
                        .edgesIgnoringSafeArea(.all)
                }
                
                if let errorMessage = errorMessage {
                    errorView(errorMessage: errorMessage)
                } else {
                    weatherContent
                }
            }
        }
    }
    
    private var weatherContent: some View {
        Group {
            if defaultCity == "Your location" {
                if let location = locationManager.location {
                    if let cityName = self.cityName {
                        weatherView(for: cityName)
                            .onAppear {
                                // Ensure cityName is set before loading weather data
                                fetchCityName(from: location) { resolvedCityName in
                                    self.cityName = resolvedCityName
                                    self.loadWeatherData(for: resolvedCityName)
                                }
                            }
                    } else {
                        Text("Fetching city name...")
                            .onAppear {
                                fetchCityName(from: location) { resolvedCityName in
                                    self.cityName = resolvedCityName
                                    self.loadWeatherData(for: resolvedCityName)
                                }
                            }
                    }
                } else {
                    Text("Unable to get location.")
                }
            } else {
                weatherView(for: defaultCity)
            }
        }
    }
    
    private func weatherView(for city: String) -> some View {
        WeatherView(cityName: city,
                    currentWeather: $currentWeather,
                    forecast: $forecast,
                    pollution: $pollution,
                    errorMessage: $errorMessage,
                    isFavourite: $isFavourite,
                    modelContext: modelContext)
            .onAppear {
                self.cityName = city
                self.loadWeatherData(for: city)
                self.checkIfFavourite()
            }
    }
    
    private func errorView(errorMessage: String) -> some View {
        VStack {
            Text("Error: \(errorMessage)")
                .foregroundColor(.red)
                .padding()
            Button(action: {
                loadWeatherData()
            }) {
                Text("Retry")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Data Fetching
    private func loadWeatherData(for city: String? = nil) {
        let resolvedCity = city ?? cityName ?? locationManager.cityName
        
        if resolvedCity == "Unknown" {
            locationManager.requestLocation { result in
                switch result {
                case .success(let location):
                    fetchCityName(from: location) { resolvedCityName in
                        self.cityName = resolvedCityName
                        self.fetchWeatherData(for: resolvedCityName)
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to get location: \(error.localizedDescription)"
                }
            }
        } else {
            fetchWeatherData(for: resolvedCity)
        }
    }
    
    private func fetchWeatherData(for city: String) {
        API.shared.fetchCurrentWeatherData(forCity: city) { result in
            switch result {
            case .success(let weatherData):
                currentWeather = weatherData
                if let icon = weatherData.weather.first?.icon {
                    mainIcon = icon
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        
        API.shared.fetchForecastData(forCity: city) { result in
            switch result {
            case .success(let forecastData):
                forecast = forecastData
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        
        API.shared.fetchAirPollutionData(forCity: city) { result in
            switch result {
            case .success(let pollutionData):
                pollution = pollutionData
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Favourites Management
    private func toggleFavourite() {
        if isFavourite {
            removeFromFavourites()
        } else {
            addToFavourites()
        }
        isFavourite.toggle()
    }
    
    private func addToFavourites() {
        guard let cityName = cityName, !cityName.isEmpty else { return }
        
        let newFavourite = FavouriteCity(name: cityName)
        newFavourite.temperature = currentWeather?.main.temp
        newFavourite.weatherIcon = currentWeather?.weather.first?.icon
        
        modelContext.insert(newFavourite)
    }
    
    private func removeFromFavourites() {
        guard let cityName = cityName else { return }
        
        if let cityToRemove = cities.first(where: { $0.name == cityName }) {
            modelContext.delete(cityToRemove)
        }
    }
    
    private func checkIfFavourite() {
        if let cityName = cityName {
            isFavourite = cities.contains(where: { $0.name == cityName })
        }
    }
    
    // MARK: - Helper Functions
    private func fetchCityName(from location: CLLocation, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                completion("Unknown")
                return
            }
            
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? "Unknown"
                completion(city)
            } else {
                print("No placemark found, setting city as Unknown")
                completion("Unknown")
            }
        }
    }
    
    private func gradientBackground(for icon: String) -> some View {
        Group {
            if backgroundStyle == .gradient {
                gradientBackground(for: icon)
            } else {
                Color.clear
            }
        }
        .onAppear {
            mainIcon = icon
        }
    }
}

#Preview {
    MainView()
}
