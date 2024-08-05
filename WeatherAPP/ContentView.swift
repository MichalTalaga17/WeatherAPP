import SwiftUI

struct ContentView: View {
    @State private var cityName = "Zembrzyce"
    @State private var weatherData: WeatherData?
    @State private var icon = "cloud.moon.rain.fill"
    @State private var backgroundGradient = LinearGradient(gradient: Gradient(colors: [Color.black]), startPoint: .top, endPoint: .bottom)
    
    
   
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Text("Pogoda")
                    .font(.largeTitle .bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 10) {
                    TextField("Podaj miasto", text: $cityName)
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(8)
                    
                    Button(action: {
                        Task {
                            await fetchWeatherData()
                        }
                    }) {
                        Text("Wyszukaj")
                            .font(.callout)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.bottom, 20)
            
            Spacer()
            
            if let weatherData = weatherData, let currentWeather = weatherData.list.first {
                VStack(alignment: .leading, spacing: 10) {
                    // City Information Block
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
                    
                    // Current Weather Block
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Temperatura: \(kelvinToCelsius(currentWeather.main.temp))")
                            Text("Zachmurzenie: \(currentWeather.clouds.all)%")
                            Text("Opis pogody: \(currentWeather.weather.first?.description ?? "")")
                        }
                        .padding()
                        Spacer()
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                    
                    // Weather Forecast Block
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            ForEach(weatherData.list.prefix(20), id: \.dt) { item in
                                VStack(alignment: .leading) {
                                    if let timestamp = dateToTimestamp(dateString: item.dt_txt) {
                                        Text(formatDate(timestamp: Int(timestamp), formatType: .timeOnly))
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
                                    Text("\(item.clouds.all)%")
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
        }
        .padding()
        .background(backgroundGradient) // Używaj gradientu z zmiennej stanu
        .foregroundColor(.white)
    }
    
    
    
    func fetchWeatherData() async {
        do {
            let cityNameCopy = cityName
            let _: () = try await API.shared.fetchWeatherData(forCity: cityNameCopy) { result in
                switch result {
                case .success(let data):
                    self.weatherData = data
                    // Update icon based on fetched data
                    if let currentWeather = data.list.first {
                        let newIcon = iconMap[currentWeather.weather.first?.icon ?? ""] ?? "unknown"
                        self.icon = newIcon
                        // Update the background gradient
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
    ContentView()
}
