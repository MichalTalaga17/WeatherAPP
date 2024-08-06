import SwiftUI

struct LocationWeatherView: View {
    let cityName: String
    @State private var weatherData: WeatherData?
    @State private var backgroundGradient = LinearGradient(gradient: Gradient(colors: [Color.black]), startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        VStack {
            if let weatherData = weatherData, let currentWeather = weatherData.list.first {
                VStack(alignment: .leading, spacing: 10) {
                    
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(kelvinToCelsius(currentWeather.main.temp))
                                .font(.largeTitle.bold())
                        }
                        .padding()
                        Spacer()
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(weatherData.city.name)")
                                .font(.title2.bold())
                            Text("Wschód słońca: \(formatDate(timestamp: weatherData.city.sunrise, formatType: .timeOnly))")
                            Text("Zachód słońca: \(formatDate(timestamp: weatherData.city.sunset, formatType: .timeOnly))")
                        }
                        .padding()
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Temperatura: \(kelvinToCelsius(currentWeather.main.temp))")
                            Text("Odczuwalna: \(kelvinToCelsius(currentWeather.main.feels_like))")
                            Text("Min: \(kelvinToCelsius(currentWeather.main.temp_min)), Max: \(kelvinToCelsius(currentWeather.main.temp_max))")
                            Text("Wilgotność: \(currentWeather.main.humidity)%")
                            Text("Ciśnienie: \(currentWeather.main.pressure) hPa")
                            Text("Zachmurzenie: \(currentWeather.clouds.all)%")
                            Text("Opis pogody: \(currentWeather.weather.first?.description ?? "")")
                            Text("Widoczność: \(currentWeather.visibility) m")
                            Text("Prędkość wiatru: \(String(format: "%.0f", currentWeather.wind.speed)) m/s \(windDirection(from: currentWeather.wind.deg))")
                            Text("Opady deszczu: \(currentWeather.rain?.h1 ?? 0) mm (1h), \(currentWeather.rain?.h3 ?? 0) mm (3h)")
                            
                            if let snow = currentWeather.snow {
                                Text("Opady śniegu: \(snow.h1 ?? 0) mm (1h), \(snow.h3 ?? 0) mm (3h)")
                            }
                        }
                        .padding()
                        Spacer()
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            ForEach(weatherData.list.prefix(20), id: \.dt) { item in
                                VStack(alignment: .center) {
                                    if let timestamp = dateToTimestamp(dateString: item.dt_txt) {
                                        Text(formatDate(timestamp: Int(timestamp), formatType: .hourOnly))
                                            .font(.subheadline)
                                    } else {
                                        Text(item.dt_txt)
                                            .font(.subheadline)
                                    }
                                    weatherIcon(for: (item.weather.first?.icon)!)
                                    Text(kelvinToCelsius(item.main.temp))
                                        .font(.title2.bold())
                                    Text(kelvinToCelsius(item.main.feels_like))
                                        .font(.body)
                                    Text("\(String(format: "%.0f", item.pop * 100))%")
                                        .font(.body)
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.25)
                            }
                        }
                        .padding([.top, .bottom, .trailing])
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                    
                    Spacer()
                }
            } else {
                Spacer()
            }
            Spacer()
            HStack {
                Button {
                    print("Ulubione")
                } label: {
                    Text("Dodaj do ulubionych")
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(30)
                }
            }
            .padding(.bottom)
        }
        .padding()
        .background(backgroundGradient)
        .foregroundColor(.white)
        .onAppear {
            Task {
                await fetchWeatherData()
            }
        }
    }
    
    func fetchWeatherData() async {
        do {
            let _: () = try await API.shared.fetchWeatherData(forCity: cityName) { result in
                switch result {
                case .success(let data):
                    self.weatherData = data
                    if let currentWeather = data.list.first {
                        let newIcon = iconMap[currentWeather.weather.first?.icon ?? ""] ?? "unknown"
                        self.backgroundGradient = gradientBackground(for: newIcon)
                    }
                case .failure(let error):
                    print("Błąd: \(error)")
                }
            }
        } catch {
            print("Błąd podczas pobierania danych: \(error)")
        }
    }
}

#Preview {
    LocationWeatherView(cityName: "Zembrzyce")
}
