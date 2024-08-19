import SwiftUI

struct WeatherView2: View {
    // MARK: - Properties
    @AppStorage("airQuality") private var airQuality: Bool = true
    @AppStorage("minimalistMode") private var minimalistMode: Bool = false
    
    @StateObject var locationManager = LocationManager()
    
    @State private var currentWeather: CurrentData?
    @State private var forecast: ForecastData?
    @State private var pollution: PollutionData?
    @State private var errorMessage: String?
    
    var cityName: String?
    
    // MARK: - Body
    var body: some View {
        VStack {
            let displayCityName = cityName ?? locationManager.cityName

            if displayCityName != "Unknown" {
                Text("City: \(displayCityName)")
                    .font(.title)
                    .padding(.bottom)
                
                WeatherContentView(
                    currentWeather: currentWeather,
                    forecast: forecast,
                    pollution: pollution,
                    minimalistMode: minimalistMode,
                    airQuality: airQuality
                )
            } else {
                Text("Fetching location...")
            }
            
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding(.top)
            }
        }
        .padding()
        .onAppear {
            loadWeatherData()
        }
    }
    
    // MARK: - Data Fetching
    private func loadWeatherData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let validCityName = cityName ?? (locationManager.cityName != "Unknown" ? locationManager.cityName : nil) {
                fetchWeatherData(for: validCityName)
            } else {
                errorMessage = "Unable to determine city name."
            }
        }
    }
    
    private func fetchWeatherData(for city: String) {
        let api = API.shared
        
        api.fetchCurrentWeatherData(forCity: city) { result in
            handleAPIResult(result, assigningTo: &currentWeather)
        }
        
        api.fetchForecastData(forCity: city) { result in
            handleAPIResult(result, assigningTo: &forecast)
        }
        
        if airQuality {
            api.fetchAirPollutionData(forCity: city) { result in
                handleAPIResult(result, assigningTo: &pollution)
            }
        }
    }
    
    private func handleAPIResult<T>(_ result: Result<T, Error>, assigningTo property: inout T?) {
        switch result {
        case .success(let data):
            property = data
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Weather Content View
struct WeatherContentView: View {
    let currentWeather: CurrentData?
    let forecast: ForecastData?
    let pollution: PollutionData?
    let minimalistMode: Bool
    let airQuality: Bool
    
    var body: some View {
        VStack {
            if let weather = currentWeather {
                if minimalistMode {
                    MinimalistWeatherDetailsView(weather: weather)
                } else {
                    WeatherDetailsView(weather: weather)
                }
            }
            
            if let forecast = forecast, !minimalistMode {
                ForecastView(forecast: forecast)
            }
            
            if airQuality, let pollution = pollution, !minimalistMode {
                AirPollutionView(pollution: pollution)
            }
        }
    }
}

// MARK: - Minimalist Weather View
struct MinimalistWeatherDetailsView: View {
    @AppStorage("iconsColorsBasedOnWeather") private var iconsColorsBasedOnWeather: Bool = true
    let weather: CurrentData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            WeatherDetailRow(title: "Temperature", value: "\(Int(weather.main.temp))°C")
            WeatherDetailRow(title: "Feels Like", value: "\(Int(weather.main.feels_like))°C")
            WeatherDetailRow(title: "Humidity", value: "\(weather.main.humidity)%")
            WeatherDetailRow(title: "Wind Speed", value: "\(Int(weather.wind.speed)) m/s")
        }
        .padding(.horizontal)
    }
}



// MARK: - Forecast View
struct ForecastView: View {
    @AppStorage("iconsColorsBasedOnWeather") private var iconsColorsBasedOnWeather: Bool = true
    let forecast: ForecastData
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Forecast")
                .font(.headline)
                .padding(.top)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(forecast.list.prefix(10), id: \.dt) { entry in
                        VStack {
                            Text("\(extractHour(from: entry.dt_txt))")
                            IconConvert(for: entry.weather.first?.icon ?? "", useWeatherColors: iconsColorsBasedOnWeather)
                            Text("\(Int(entry.main.temp))°")
                            Text("\(Int(entry.main.feels_like))°")
                        }
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Air Pollution View
struct AirPollutionView: View {
    let pollution: PollutionData
    
    var body: some View {
        ScrollView(.horizontal) {
            if let pollutionEntry = pollution.list.first {
                HStack {
                    PollutionComponentView(value: pollutionEntry.components.pm2_5, label: "PM2.5")
                    PollutionComponentView(value: pollutionEntry.components.pm10, label: "PM10")
                    PollutionComponentView(value: Double(pollutionEntry.main.aqi), label: "AQI")
                    PollutionComponentView(value: pollutionEntry.components.co, label: "CO")
                    PollutionComponentView(value: pollutionEntry.components.no2, label: "NO2")
                }
            }
        }
        .padding()
    }
}

// MARK: - Pollution Component View
struct PollutionComponentView: View {
    let value: Double
    let label: String
    
    var body: some View {
        VStack {
            Text("\(Int(value))")
            Text(label)
        }
    }
}

#Preview {
    WeatherView2(cityName: "Zembrzyce")
}
