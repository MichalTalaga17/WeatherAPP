import SwiftUI

struct WeatherView: View {
    // MARK: - Properties
    @AppStorage("airQuality") private var airQuality: Bool = true
    @AppStorage("iconsColorsBasedOnWeather") private var iconsColorsBasedOnWeather: Bool = true
    
    @StateObject var locationManager = LocationManager()
    
    @State private var currentWeather: CurrentData?
    @State private var forecast: ForecastData?
    @State private var pollution: PollutionData?
    @State private var errorMessage: String?
    
    var cityName: String?
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                if let weather = currentWeather {
                    VStack(alignment: .center, spacing: 10) {
                        if (cityName != nil){
                            Text("\(weather.name), \(weather.sys.country)")
                                .font(.title3)
                        } else{
                            Text(locationManager.cityName)
                                .font(.title3)
                        }
                        
                        Text("\(Int(weather.main.temp))°")
                            .font(.system(size: 80))
                        if let weatherDescription = weather.weather.first?.description {
                            Text(weatherDescription.capitalized)
                        }
                        Text("From \(Int(weather.main.temp_min))° to \(Int(weather.main.temp_max))°")
                            .font(.callout)
                        
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 10), count: 2), spacing: 10) {
                            VStack{
                                Spacer()
                                HStack {
                                    Spacer()
                                    HStack(spacing: 15){
                                        VStack{
                                            IconConvert(for: "sunrise.fill", useWeatherColors: iconsColorsBasedOnWeather)
                                            Text(formatUnixTimeToHourAndMinute(weather.sys.sunrise, timezone: weather.timezone))
                                        }
                                        VStack{
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
                            
                            VStack{
                                Spacer()
                                HStack {
                                    Spacer()
                                    HStack(alignment: .center) {
                                        if let icon = weather.weather.first?.icon {
                                            IconConvert(for: icon, useWeatherColors: iconsColorsBasedOnWeather)
                                        }
                                        VStack{
                                            Text("\(weather.clouds.all)%")
                                                .font(.title)
                                                .fontWeight(.bold)
                                            
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
                        VStack{
                            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 0), count: 2), spacing: 0) {
                                WeatherDetailRow(title: "Humidity", value: "\(weather.main.humidity)%")
                                WeatherDetailRow(title: "Pressure", value: "\(weather.main.pressure) hPa")
                                
                            }
                            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 0), count: 2), spacing: 0) {
                                WeatherDetailRow(title: "Wind Speed", value: "\(Int(weather.wind.speed)) m/s")
                                if let rain = weather.rain?.hour1 {
                                    WeatherDetailRow(title: "Rain", value: "\(rain) mm (1h)")
                                }else if let snow = weather.snow?.hour1 {
                                    WeatherDetailRow(title: "Snow", value: "\(snow) mm (1h)")
                                }else{
                                    WeatherDetailRow(title: "Precipitation", value: "0")
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        
                        
                        
                        
                        
                    }
                }
                if let forecast = forecast {
                        
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
                
                // Air Pollution
                if airQuality, let pollution = pollution {
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
                
                // Fetching or Error Message
                if currentWeather == nil && forecast == nil && pollution == nil {
                    Text("Fetching data...")
                }
                
                if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding(.top)
                }
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let cityName = cityName {
                    fetchWeatherData(for: cityName)
                } else if locationManager.cityName != "Unknown" {
                    fetchWeatherData(for: locationManager.cityName)
                } else {
                    errorMessage = "Unable to determine city name."
                }
            }
        }
    }
    
    // MARK: - Data Fetching
    private func fetchWeatherData(for city: String) {
        if city != "Unknown" {
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
        } else {
            errorMessage = "City name is Unknown. Cannot fetch weather data."
        }
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
                    .font(.title)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption)
            }
            Spacer()
        }
    }
}

#Preview {
    WeatherView(cityName: "Zembrzyce")
}
