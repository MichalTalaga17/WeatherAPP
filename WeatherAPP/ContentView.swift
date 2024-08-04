import SwiftUI

struct ContentView: View {
    @State private var cityName = ""
    @State private var weatherData: WeatherData?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                            HStack {
                                GeometryReader { geometry in
                                    HStack(spacing: 3) {
                                        TextField("Podaj miasto", text: $cityName)
                                            .padding()
                                            .background(Color.black.opacity(0.1))
                                            .cornerRadius(8)
                                            .frame(width: geometry.size.width * 0.7)
                                        
                                        Button(action: {
                                            Task {
                                                await fetchWeatherData()
                                            }
                                        }) {
                                            Text("Wyszukaj")
                                                .font(.callout)
                                                .padding()
                                                .background(Color.black.opacity(0.7))
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                                .frame(width: geometry.size.width * 0.3)
                                        }
                                    }
                                }
                            }

                if let weatherData = weatherData {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // City Information Block
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(weatherData.city.name)")
                                    .font(.headline)
                                Text("\(weatherData.city.country)")
                                    .font(.subheadline)
                                Text("Wschód słońca: \(formatDate(timestamp: weatherData.city.sunrise))")
                                Text("Zachód słońca: \(formatDate(timestamp: weatherData.city.sunset))")
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)

                            // Current Weather Block
                            if let currentWeather = weatherData.list.first {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Pogoda teraz")
                                        .font(.headline)
                                    Text("Temperatura: \(currentWeather.main.temp) K")
                                    Text("Odczuwalna temperatura: \(currentWeather.main.feels_like) K")
                                    Text("Temperatura min: \(currentWeather.main.temp_min) K")
                                    Text("Temperatura max: \(currentWeather.main.temp_max) K")
                                    Text("Ciśnienie: \(currentWeather.main.pressure) hPa")
                                    Text("Wilgotność: \(currentWeather.main.humidity)%")
                                    Text("Widoczność: \(currentWeather.visibility) m")
                                    Text("Zachmurzenie: \(currentWeather.clouds.all)%")
                                    Text("Wiatr: \(currentWeather.wind.speed) m/s, kierunek: \(currentWeather.wind.deg)°")
                                    if let gust = currentWeather.wind.gust {
                                        Text("Podmuchy wiatru: \(gust) m/s")
                                    }
                                    Text("Opis pogody: \(currentWeather.weather.first?.description ?? "")")
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            }

                            // Weather Forecast Block
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Pogoda na następne 9 godzin")
                                    .font(.headline)
                                ForEach(weatherData.list.prefix(3), id: \.dt) { item in
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Data: \(item.dt_txt)")
                                        Text("Temperatura: \(item.main.temp) K")
                                        Text("Odczuwalna temperatura: \(item.main.feels_like) K")
                                        Text("Ciśnienie: \(item.main.pressure) hPa")
                                        Text("Wilgotność: \(item.main.humidity)%")
                                        Text("Zachmurzenie: \(item.clouds.all)%")
                                        Text("Wiatr: \(item.wind.speed) m/s, kierunek: \(item.wind.deg)°")
                                        if let gust = item.wind.gust {
                                            Text("Podmuchy wiatru: \(gust) m/s")
                                        }
                                        Text("Opis pogody: \(item.weather.first?.description ?? "")")
                                    }
                                    .padding()
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding()
            .navigationTitle("Pogoda")
        }
    }

    func fetchWeatherData() async {
        do {
                    let _: () = try await API.shared.fetchWeatherData(forCity: cityName) { result in
                        switch result {
                        case .success(let data):
                            self.weatherData = data
                        case .failure(let error):
                            print("Błąd: \(error)")
                        }
                    }
                } catch {
                    print("Błąd podczas pobierania danych: \(error)")
                }
    }

    func formatDate(timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
}

#Preview {
    ContentView()
}
