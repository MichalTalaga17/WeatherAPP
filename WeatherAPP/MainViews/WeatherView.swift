//
//  Weather.swift
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
                } else if let location = locationManager.location {
                    Text("Fetching data for location...")
                        .onAppear {
                            fetchCityName(from: location) { cityName in
                                self.cityName = cityName
                                self.loadWeatherData()
                            }
                        }
                } else {
                    Text("Fetching location...")
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
                    Text(isFavourite ? "Remove from Favourites" : "Add to Favourites")
                        .font(.footnote)
                }
                .padding(10)
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
                .foregroundColor(.white)
            }
            .padding(.bottom)
            
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 10), count: 2), spacing: 10) {
                weatherInfoView(weather)
                weatherAdditionalInfoView(weather)
            }
            
            weatherDetailsGrid(weather)
        }
    }
    
    private func weatherInfoView(_ weather: CurrentData) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                HStack(spacing: 15) {
                    VStack {
                        IconConvert(for: "sunrise.fill", useWeatherColors: iconsColorsBasedOnWeather)
                        Text(formatUnixTimeToHourAndMinute(weather.sys.sunrise, timezone: weather.timezone))
                    }
                    VStack {
                        IconConvert(for: "sunset.fill", useWeatherColors: iconsColorsBasedOnWeather)
                        Text(formatUnixTimeToHourAndMinute(weather.sys.sunset, timezone: weather.timezone))
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.2))
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
        .background(Color.white.opacity(0.2))
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
        .background(Color.white.opacity(0.2))
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
        .background(Color.white.opacity(0.2))
        .cornerRadius(8)
    }
    
    private func getPrecipitationInfo(_ weather: CurrentData) -> String {
        if let rain = weather.rain?.hour1 {
            return "\(rain) mm"
        } else if let snow = weather.snow?.hour1 {
            return "\(snow) mm"
        } else {
            return "0"
        }
    }
    
    // MARK: - Background Handling
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
        .background(Color.white.opacity(0.2))
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

struct WeatherDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Text(value)
                    .font(.title2 .bold())
                Text(title)
                    .font(.caption)
            }
            Spacer()
        }
    }
}
#Preview {
    WeatherView(cityName: "New York")
}

