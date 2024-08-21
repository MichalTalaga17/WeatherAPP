////
////  MainView.swift
////  WeatherAPP
////
////  Created by Michał Talaga on 19/08/2024.
////
//
//import SwiftUI
//import CoreLocation
//import SwiftData
//
//struct MainView2: View {
//    // MARK: - Properties
//    @AppStorage("airQuality") private var airQuality: Bool = true
//    @AppStorage("iconsColorsBasedOnWeather") private var iconsColorsBasedOnWeather: Bool = true
//    @AppStorage("backgroundStyle") private var backgroundStyle: BackgroundStyle = .gradient
//    @AppStorage("mainIcon") private var mainIcon: String = ""
//    @AppStorage("defaultCity") private var defaultCity: String = "Your location"
//    
//    @Environment(\.modelContext) private var modelContext
//    @StateObject private var locationManager = LocationManager()
//    
//    @Query private var cities: [FavouriteCity]
//    
//    @State private var currentWeather: CurrentData?
//    @State private var forecast: ForecastData?
//    @State private var pollution: PollutionData?
//    @State private var errorMessage: String?
//    
//    @State private var cityName: String?
//    @State private var isFavourite: Bool = false
//    
//    init() {
//        _cityName = State(initialValue: nil)
//    }
//    
//    // MARK: - Body
//    var body: some View {
//        NavigationView {
//            ZStack {
//                if backgroundStyle == .gradient {
//                    backgroundView(for: currentWeather?.weather.first?.icon ?? "01d")
//                        .edgesIgnoringSafeArea(.all)
//                }
//                
//                if errorMessage != nil {
//                    ErrorView(errorMessage: $errorMessage, retryAction: loadWeatherData)
//                } else if defaultCity == "Your location" {
//                    LocationBasedWeatherView(locationManager: locationManager, cityName: $cityName, fetchCityName: fetchCityName, loadWeatherData: loadWeatherData)
//                } else {
//                    WeatherContentView(
//                        currentWeather: $currentWeather,
//                        forecast: $forecast,
//                        pollution: $pollution,
//                        airQuality: $airQuality,
//                        isFavourite: $isFavourite,
//                        cityName: $cityName,
//                        toggleFavourite: toggleFavourite,
//                        weatherDetails: weatherDetails,
//                        forecastView: forecastView,
//                        weatherInfoView: weatherInfoView,
//                        weatherAdditionalInfoView: weatherAdditionalInfoView,
//                        weatherDetailsGrid: weatherDetailsGrid
//                    )
//                }
//            }
//        }
//        .onAppear {
//            if defaultCity == "Your location" && locationManager.location != nil {
//                loadWeatherData()
//            } else if !defaultCity.isEmpty {
//                loadWeatherData(for: locationManager.cityName)
//            }
//        }
//    }
//    
//    // MARK: - Background Handling
//    private func backgroundView(for icon: String) -> some View {
//        Group {
//            if backgroundStyle == .gradient {
//                gradientBackground(for: icon)
//            } else {
//                Color.clear
//            }
//        }
//        .onAppear {
//            mainIcon = icon
//        }
//    }
//    
//    // MARK: - Data Fetching
//    private func loadWeatherData(for city: String? = nil) {
//        let resolvedCity = city ?? cityName ?? locationManager.cityName
//        
//        if resolvedCity == "Unknown" {
//            locationManager.requestLocation { result in
//                switch result {
//                case .success(let location):
//                    fetchCityName(from: location) { resolvedCityName in
//                        self.cityName = resolvedCityName
//                        self.fetchWeatherData(for: resolvedCityName)
//                    }
//                case .failure(let error):
//                    self.errorMessage = "Failed to get location: \(error.localizedDescription)"
//                }
//            }
//        } else {
//            fetchWeatherData(for: resolvedCity)
//        }
//    }
//    
//    private func fetchWeatherData(for city: String) {
//        API.shared.fetchCurrentWeatherData(forCity: city) { result in
//            switch result {
//            case .success(let weatherData):
//                currentWeather = weatherData
//                if let icon = weatherData.weather.first?.icon {
//                    mainIcon = icon
//                }
//            case .failure(let error):
//                errorMessage = error.localizedDescription
//            }
//        }
//        
//        API.shared.fetchForecastData(forCity: city) { result in
//            switch result {
//            case .success(let forecastData):
//                forecast = forecastData
//            case .failure(let error):
//                errorMessage = error.localizedDescription
//            }
//        }
//        
//        API.shared.fetchAirPollutionData(forCity: city) { result in
//            switch result {
//            case .success(let pollutionData):
//                pollution = pollutionData
//            case .failure(let error):
//                errorMessage = error.localizedDescription
//            }
//        }
//    }
//    
//    // MARK: - Favourites Management
//    private func toggleFavourite() {
//        if isFavourite {
//            removeFromFavourites()
//        } else {
//            addToFavourites()
//        }
//        isFavourite.toggle()
//    }
//    
//    private func addToFavourites() {
//        guard let cityName = cityName, !cityName.isEmpty else { return }
//        
//        let newFavourite = FavouriteCity(name: cityName)
//        newFavourite.temperature = currentWeather?.main.temp
//        newFavourite.weatherIcon = currentWeather?.weather.first?.icon
//        
//        modelContext.insert(newFavourite)
//    }
//    
//    private func removeFromFavourites() {
//        guard let cityName = cityName else { return }
//        
//        if let cityToRemove = cities.first(where: { $0.name == cityName }) {
//            modelContext.delete(cityToRemove)
//        }
//    }
//    
//    private func checkIfFavourite() {
//        if let cityName = cityName {
//            isFavourite = cities.contains(where: { $0.name == cityName })
//        }
//    }
//    
//    // MARK: - Helper Functions
//    private func fetchCityName(from location: CLLocation, completion: @escaping (String) -> Void) {
//        let geocoder = CLGeocoder()
//        geocoder.reverseGeocodeLocation(location) { placemarks, error in
//            if let error = error {
//                print("Reverse geocoding failed: \(error.localizedDescription)")
//                completion("Unknown")
//                return
//            }
//            
//            if let placemark = placemarks?.first {
//                let city = placemark.locality ?? "Unknown"
//                completion(city)
//            } else {
//                print("No placemark found, setting city as Unknown")
//                completion("Unknown")
//            }
//        }
//    }
//    
//    private func weatherDetails(for weather: CurrentData) -> some View {
//        WeatherDetailsView(
//            weather: weather,
//            cityName: cityName,
//            defaultCity: defaultCity,
//            iconsColorsBasedOnWeather: iconsColorsBasedOnWeather,
//            toggleFavourite: toggleFavourite,
//            isFavourite: isFavourite
//        )
//    }
//    
//    private func weatherInfoView(_ weather: CurrentData) -> some View {
//        VStack {
//            Spacer()
//            HStack {
//                Spacer()
//                HStack(spacing: 30) {
//                    VStack {
//                        IconConvert(for: "sunrise.fill", useWeatherColors: iconsColorsBasedOnWeather)
//                        Text(formatUnixTimeToHourAndMinute(weather.sys.sunrise, timezone: weather.timezone))
//                    }
//                    VStack {
//                        IconConvert(for: "sunset.fill", useWeatherColors: iconsColorsBasedOnWeather)
//                        Text(formatUnixTimeToHourAndMinute(weather.sys.sunset, timezone: weather.timezone))
//                    }
//                }
//                Spacer()
//            }
//            Spacer()
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 5)
//        .background(Color.white.opacity(0.2))
//        .cornerRadius(8)
//    }
//    
//    private func weatherAdditionalInfoView(_ weather: CurrentData) -> some View {
//        VStack {
//            Spacer()
//            HStack {
//                Spacer()
//                HStack(alignment: .center) {
//                    if let icon = weather.weather.first?.icon {
//                        IconConvert(for: icon, useWeatherColors: iconsColorsBasedOnWeather)
//                    }
//                    VStack {
//                        Text("\(weather.clouds.all)%")
//                            .font(.title2 .bold())
//                        Text("\(weather.visibility / 1000) km")
//                    }
//                }
//                Spacer()
//            }
//            Spacer()
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 5)
//        .background(Color.white.opacity(0.2))
//        .cornerRadius(8)
//    }
//    
//    private func weatherDetailsGrid(_ weather: CurrentData) -> some View {
//        VStack {
//            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 0), count: 2), spacing: 0) {
//                WeatherDetailRow(title: "Humidity", value: "\(weather.main.humidity)%")
//                WeatherDetailRow(title: "Pressure", value: "\(weather.main.pressure) hPa")
//            }
//            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 0), count: 2), spacing: 0) {
//                WeatherDetailRow(title: "Wind Speed", value: "\(Int(weather.wind.speed)) m/s")
//                WeatherDetailRow(title: "Precipitation", value: getPrecipitationInfo(weather))
//            }
//        }
//        .padding()
//        .background(Color.white.opacity(0.2))
//        .cornerRadius(8)
//    }
//    
//    private func forecastView(for forecast: ForecastData) -> some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack {
//                ForEach(forecast.list.prefix(10), id: \.dt) { entry in
//                    VStack {
//                        Text("\(extractHour(from: entry.dt_txt))")
//                        IconConvert(for: entry.weather.first?.icon ?? "", useWeatherColors: iconsColorsBasedOnWeather)
//                        Text("\(Int(entry.main.temp))°")
//                            .font(.title2 .bold())
//                        Text("\(Int(entry.main.feels_like))°")
//                            .font(.callout)
//                    }
//                    .frame(width: UIScreen.main.bounds.width * 0.15)
//                }
//            }
//        }
//        .padding()
//        .background(Color.white.opacity(0.2))
//        .cornerRadius(8)
//    }
//    
//    private func getPrecipitationInfo(_ weather: CurrentData) -> String {
//        if let rain = weather.rain?.hour1 {
//            return "\(rain) mm"
//        } else if let snow = weather.snow?.hour1 {
//            return "\(snow) mm"
//        } else {
//            return "0"
//        }
//    }
//}
//struct ErrorView: View {
//    @Binding var errorMessage: String?
//    let retryAction: () -> Void
//    
//    var body: some View {
//        VStack {
//            Text("Error: \(errorMessage ?? "")")
//                .foregroundColor(.red)
//                .padding()
//            Button(action: retryAction) {
//                Text("Retry")
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//        }
//    }
//}
//struct LocationBasedWeatherView: View {
//    @ObservedObject var locationManager: LocationManager
//    @Binding var cityName: String?
//    let fetchCityName: (CLLocation, @escaping (String) -> Void) -> Void
//    let loadWeatherData: (String?) -> Void
//    
//    var body: some View {
//        Group {
//            if let location = locationManager.location {
//                VStack {
//                    Text("Fetching data for location...")
//                        .onAppear {
//                            fetchCityName(from: location) { resolvedCityName in
//                                self.cityName = resolvedCityName
//                                self.loadWeatherData(for: resolvedCityName)
//                            }
//                        }
//                }
//            } else {
//                VStack {
//                    Text("Fetching location...")
//                }
//            }
//        }
//    }
//}
//struct WeatherContentView: View {
//    @Binding var currentWeather: CurrentData?
//    @Binding var forecast: ForecastData?
//    @Binding var pollution: PollutionData?
//    @Binding var airQuality: Bool
//    @Binding var isFavourite: Bool
//    @Binding var cityName: String?
//    let toggleFavourite: () -> Void
//    let weatherDetails: (CurrentData) -> some View
//    let forecastView: (ForecastData) -> some View
//    let weatherInfoView: (CurrentData) -> some View
//    let weatherAdditionalInfoView: (CurrentData) -> some View
//    let weatherDetailsGrid: (CurrentData) -> some View
//    
//    var body: some View {
//        VStack(alignment: .center) {
//            if let weather = currentWeather {
//                weatherDetails(weather)
//            }
//            
//            if let forecast = forecast {
//                forecastView(forecast)
//            }
//            
//            if airQuality, let pollution = pollution {
//                PollutionDataView(pollutionEntry: pollution.list.first!)
//            }
//        }
//        .padding()
//    }
//}
//
//struct WeatherDetailsView: View {
//    let weather: CurrentData
//    let cityName: String?
//    let defaultCity: String
//    let iconsColorsBasedOnWeather: Bool
//    let toggleFavourite: () -> Void
//    let isFavourite: Bool
//    
//    var body: some View {
//        VStack(alignment: .center) {
//            VStack {
//                Text(defaultCity == "Your location" ? (cityName ?? "Unknown") : defaultCity)
//                    .font(.title3)
//                
//                Text("\(Int(weather.main.temp))°")
//                    .font(.system(size: 80))
//                
//                if let weatherDescription = weather.weather.first?.description {
//                    Text(weatherDescription.capitalized)
//                }
//                
//                Text("From \(Int(weather.main.temp_min))° to \(Int(weather.main.temp_max))°")
//                    .font(.callout)
//                
//                Button(action: {
//                    toggleFavourite()
//                }) {
//                    if isFavourite {
//                        Image(systemName: "star.fill")
//                    } else {
//                        Image(systemName: "star")
//                    }
//                }
//                .padding(10)
//                .padding(.horizontal)
//                .background(Color.white.opacity(0.2))
//                .cornerRadius(20)
//            }
//            .padding(.bottom)
//            
//            weatherInfoView(weather)
//            weatherAdditionalInfoView(weather)
//            weatherDetailsGrid(weather)
//        }
//    }
//}
//struct PollutionDataView: View {
//    let pollutionEntry: PollutionEntry
//    
//    var body: some View {
//        HStack {
//            PollutionDataDetail(value: "\(aqiDescription(for: pollutionEntry.main.aqi))", label: "AQI")
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack {
//                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.pm2_5))", label: "PM2.5")
//                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.pm10))", label: "PM10")
//                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.co))", label: "CO")
//                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.no))", label: "NO")
//                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.no2))", label: "NO2")
//                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.o3))", label: "O3")
//                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.so2))", label: "SO2")
//                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.nh3))", label: "NH3")
//                }
//            }
//        }
//        .padding()
//        .background(Color.white.opacity(0.2))
//        .cornerRadius(8)
//    }
//}
//
//struct PollutionDataDetail: View {
//    let value: String
//    let label: String
//    
//    var body: some View {
//        VStack {
//            Text(value)
//                .font(.title2 .bold())
//            Text(label)
//                .font(.caption)
//        }
//        .frame(width: UIScreen.main.bounds.width * 0.15)
//    }
//}
//struct WeatherDetailRow: View {
//    let title: String
//    let value: String
//    
//    var body: some View {
//        HStack {
//            Spacer()
//            VStack(alignment: .center) {
//                Text(value)
//                    .font(.title2 .bold())
//                Text(title)
//                    .font(.caption)
//            }
//            Spacer()
//        }
//    }
//}
//
//#Preview{
//    MainView2()
//}
