import SwiftUI

struct ContentView: View {
    @State private var cityName = ""
    @State private var weatherData: WeatherData?

    var body: some View {
            NavigationView {
                VStack {
                    TextField("Podaj miasto", text: $cityName)
                        .padding()
                    Button("Wyszukaj") {
                        Task {
                            await fetchWeatherData()
                        }
                    }

                    if let weatherData = weatherData {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Miasto: \(weatherData.city.name)")
                                Text("Kraj: \(weatherData.city.country)")
                                Text("Populacja: \(weatherData.city.population)")
                                Text("Współrzędne: \(weatherData.city.coord.lat), \(weatherData.city.coord.lon)")
                                Text("Strefa czasowa: \(weatherData.city.timezone)")
                                Text("Wschód słońca: \(formatDate(timestamp: weatherData.city.sunrise))")
                                Text("Zachód słońca: \(formatDate(timestamp: weatherData.city.sunset))")
                                
                                ForEach(weatherData.list, id: \.dt) { item in
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Data: \(item.dt_txt)")
                                        Text("Temperatura: \(item.main.temp) K")
                                        Text("Odczuwalna temperatura: \(item.main.feels_like) K")
                                        Text("Temperatura min: \(item.main.temp_min) K")
                                        Text("Temperatura max: \(item.main.temp_max) K")
                                        Text("Ciśnienie: \(item.main.pressure) hPa")
                                        Text("Poziom morza: \(item.main.sea_level) hPa")
                                        Text("Poziom gruntu: \(item.main.grnd_level) hPa")
                                        Text("Wilgotność: \(item.main.humidity)%")
                                        Text("Temperatura kalibracyjna: \(item.main.temp_kf) K")
                                        Text("Widoczność: \(item.visibility) m")
                                        Text("Zachmurzenie: \(item.clouds.all)%")
                                        Text("Wiatr: \(item.wind.speed) m/s, kierunek: \(item.wind.deg)°")
                                        if let gust = item.wind.gust {
                                            Text("Podmuchy wiatru: \(gust) m/s")
                                        }
                                        Text("Opady: \(item.pop * 100)%")
                                        Text("Opis pogody: \(item.weather.first?.description ?? "")")
                                        Text("Podsystem: \(item.sys.pod)")
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
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
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: date)
    }
}


#Preview{
    ContentView()
}
