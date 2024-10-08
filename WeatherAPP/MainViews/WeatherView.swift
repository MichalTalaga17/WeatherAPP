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
    @AppStorage("backgroundStyle") private var backgroundStyle: BackgroundStyle = .animated
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var locationManager = LocationManager()
    
    @Query private var cities: [FavouriteCity]
    
    @State private var currentWeather: CurrentData?
    @State private var forecast: ForecastData?
    @State private var pollution: PollutionData?
    @State private var errorMessage: String?
    
    @State private var cityName: String?
    @State private var isFavourite: Bool = false
    
    init(cityName: String? = nil) {
        _cityName = State(initialValue: cityName)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                if backgroundStyle == .gradient {
                    backgroundView(for: currentWeather?.weather.first?.icon ?? "01d")
                        .edgesIgnoringSafeArea(.all)
                } else if backgroundStyle == .animated {
                    animatedBackground(for: currentWeather?.weather.first?.icon ?? "01d")
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Color.clear
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
                } else if cityName != nil {
                    VStack(alignment: .center) {
                        if let weather = currentWeather {
                            weatherDetails(for: weather)
                        }
                        
                        if let forecast = forecast {
                            forecastView(for: forecast)
                        }
                        
                        if airQuality, let pollution = pollution {
                            PollutionDataView(pollutionEntry: pollution.list.first!)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            if cityName != nil || locationManager.location != nil {
                loadWeatherData()
                checkIfFavourite()
            }
        }
    }
    
    // MARK: - Data Fetching
    private func loadWeatherData() {
        let city = cityName ?? locationManager.cityName
        
        if city == "Unknown" {
            locationManager.requestLocation { result in
                switch result {
                case .success(let location):
                    fetchCityName(from: location) { cityName in
                        self.cityName = cityName
                        self.fetchWeatherData(for: cityName)
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to get location: \(error.localizedDescription)"
                }
            }
        } else {
            fetchWeatherData(for: city)
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
                print("WV: Reverse geocoding failed: \(error.localizedDescription)")
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
    
    private func weatherDetails(for weather: CurrentData) -> some View {
        VStack(alignment: .center) {
            VStack {
                Text(cityName?.isEmpty == false ? "\(weather.name), \(weather.sys.country)" : locationManager.cityName)
                    .font(.title3)
                
                Text("\(Int(weather.main.temp))°")
                    .font(.system(size: 80))
                
                if let weatherDescription = weather.weather.first?.description {
                    Text(weatherDescription.capitalized)
                }
                
                Text("From \(Int(weather.main.temp_min))° to \(Int(weather.main.temp_max))°")
                    .font(.callout)
                Button(action: {
                    toggleFavourite()
                }) {
                    if isFavourite {
                        Image(systemName: "star.fill")
                    } else {
                        Image(systemName: "star")
                    }
                }
                .padding(10)
                .padding(.horizontal)
                .background(.material)
                .cornerRadius(20)
            }
            .padding(.bottom)
            
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 10), count: 2), spacing: 10) {
                weatherInfoView(weather)
                weatherAdditionalInfoView(weather)
            }
            
            weatherDetailsGrid(weather)
        }
    }
    
    func formatUnixTimeToHourAndMinute(_ unixTime: TimeInterval, timezone: Int) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let timeZone = TimeZone(secondsFromGMT: timezone) ?? TimeZone.current

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "HH:mm"

        return dateFormatter.string(from: date)
    }

    private func weatherInfoView(_ weather: CurrentData) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                HStack(spacing: 30) {
                    VStack {
                        IconConvert(for: "sunrise.fill", useWeatherColors: iconsColorsBasedOnWeather)
                        Text(formatUnixTimeToHourAndMinute(TimeInterval(weather.sys.sunrise), timezone: weather.timezone))
                    }
                    VStack {
                        IconConvert(for: "sunset.fill", useWeatherColors: iconsColorsBasedOnWeather)
                        Text(formatUnixTimeToHourAndMinute(TimeInterval(weather.sys.sunset), timezone: weather.timezone))
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(.material)
        .cornerRadius(8)
    }
    
    private func weatherAdditionalInfoView(_ weather: CurrentData) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                HStack(alignment: .center) {
                    if let icon = weather.weather.first?.icon {
                        IconConvert(for: icon, useWeatherColors: iconsColorsBasedOnWeather)
                    }
                    VStack {
                        Text("\(weather.clouds.all)%")
                            .font(.title2 .bold())
                        Text("\(weather.visibility / 1000) km")
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(.material)
        .cornerRadius(8)
    }
    
    private func weatherDetailsGrid(_ weather: CurrentData) -> some View {
        VStack {
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 0), count: 2), spacing: 0) {
                WeatherDetailRow(title: "Humidity", value: "\(weather.main.humidity)%")
                WeatherDetailRow(title: "Pressure", value: "\(weather.main.pressure) hPa")
            }
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 0), count: 2), spacing: 0) {
                WeatherDetailRow(title: "Wind Speed", value: "\(Int(weather.wind.speed)) m/s")
                WeatherDetailRow(title: "Precipitation", value: getPrecipitationInfo(weather))
            }
        }
        .padding()
        .background(.material)
        .cornerRadius(8)
    }
    
    private func forecastView(for forecast: ForecastData) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(forecast.list.prefix(10), id: \.dt) { entry in
                    VStack {
                        Text("\(extractHour(from: entry.dt_txt))")
                        IconConvert(for: entry.weather.first?.icon ?? "", useWeatherColors: iconsColorsBasedOnWeather)
                        Text("\(Int(entry.main.temp))°")
                            .font(.title2 .bold())
                        Text("\(Int(entry.main.feels_like))°")
                            .font(.callout)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.15)
                }
            }
        }
        .padding()
        .background(.material)
        .cornerRadius(8)
    }
    private func backgroundView(for icon: String) -> some View {
        Group {
            if backgroundStyle == .gradient {
                gradientBackground(for: icon)
            } else {
                Color.clear
            }
        }
    }
    
}




// MARK: - Precipitation Info
func getPrecipitationInfo(_ weather: CurrentData) -> String {
    if let rainVolume = weather.rain?.hour1 {
        return "\(rainVolume) mm/h"
    } else if let snowVolume = weather.snow?.hour1 {
        return "\(snowVolume) mm/h"
    } else {
        return "0"
    }
}

// MARK: - Preview
#Preview {
    WeatherView(cityName: "Zembrzyce")
}
