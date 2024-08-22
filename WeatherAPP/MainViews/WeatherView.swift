//
//  WeatherView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import SwiftUI
import CoreLocation
import SwiftData

struct WeatherView: View {
    // MARK: - Properties
    @AppStorage("airQuality") private var airQuality: Bool = true
    @AppStorage("iconsColorsBasedOnWeather") private var iconsColorsBasedOnWeather: Bool = true
    @AppStorage("backgroundStyle") private var backgroundStyle: BackgroundStyle = .gradient
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var locationManager = LocationManager()
    
    @Query private var cities: [FavouriteCity]
    
    @Binding var currentWeather: CurrentData?
    @Binding var forecast: ForecastData?
    @Binding var pollution: PollutionData?
    @Binding var errorMessage: String?
    @Binding var isFavourite: Bool
    
    @State private var cityName: String?
    
    init(cityName: String? = nil,
         currentWeather: Binding<CurrentData?>,
         forecast: Binding<ForecastData?>,
         pollution: Binding<PollutionData?>,
         errorMessage: Binding<String?>,
         isFavourite: Binding<Bool>,
         modelContext: ModelContext) {
        self._cityName = State(initialValue: cityName)
        self._currentWeather = currentWeather
        self._forecast = forecast
        self._pollution = pollution
        self._errorMessage = errorMessage
        self._isFavourite = isFavourite
        self._modelContext = Environment(\.modelContext).wrappedValue
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                if backgroundStyle == .gradient {
                    gradientBackground(for: currentWeather?.weather.first?.icon ?? "01d")
                        .edgesIgnoringSafeArea(.all)
                }
                
                if let errorMessage = errorMessage {
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
                } else {
                    VStack {
                        weatherInfo
                        if airQuality {
                            PollutionDataView(pollution: pollution)
                        }
                        Spacer()
                    }
                    .navigationTitle(cityName ?? "Weather")
                    .navigationBarItems(trailing: favouriteButton)
                }
            }
        }
    }
    
    private var weatherInfo: some View {
        VStack {
            if let weather = currentWeather {
                Text("\(weather.main.temp ?? 0)°")
                    .font(.largeTitle)
                Text(weather.weather.first?.description.capitalized ?? "")
                    .font(.title)
            } else {
                Text("Loading...")
            }
        }
    }
    
    private var favouriteButton: some View {
        Button(action: {
            toggleFavourite()
        }) {
            Image(systemName: isFavourite ? "star.fill" : "star")
                .foregroundColor(isFavourite ? .yellow : .gray)
        }
    }
    
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
    
    private func loadWeatherData() {
        if let cityName = cityName {
            fetchWeatherData(for: cityName)
        }
    }
    
    private func fetchWeatherData(for city: String) {
        API.shared.fetchCurrentWeatherData(forCity: city) { result in
            switch result {
            case .success(let weatherData):
                currentWeather = weatherData
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
    
    private func gradientBackground(for icon: String) -> some View {
        Group {
            if backgroundStyle == .gradient {
                gradientBackground(for: icon)
            } else {
                Color.clear
            }
        }
    }
}

#Preview {
    WeatherView(currentWeather: .constant(nil),
                forecast: .constant(nil),
                pollution: .constant(nil),
                errorMessage: .constant(nil),
                isFavourite: .constant(false),
                modelContext: ModelContext())
}
