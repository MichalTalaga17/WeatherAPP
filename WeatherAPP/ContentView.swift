import SwiftUI

struct ContentView: View {
    @State private var cityName = "Zembrzyce"
    @State private var weatherData: WeatherData?
    var body: some View {
        NavigationView {
            VStack {
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
                            .border(Color.gray, width: 2)
                
                if let weatherData = weatherData {
                        VStack( spacing: 20) {
                            
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
                                    Text("Temperatura: \(currentWeather.main.temp) K")
                                    Text("Odczuwalna temperatura: \(currentWeather.main.feels_like) K")
                                    Text("Zachmurzenie: \(currentWeather.clouds.all)%")
                                    Text("Opis pogody: \(currentWeather.weather.first?.description ?? "")")
                                }
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                            }

                            // Weather Forecast Block
                            ScrollView(.horizontal) {
                                HStack(alignment: .top, spacing: 10) {
                                    ForEach(weatherData.list.prefix(10), id: \.dt) { item in
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text(item.dt_txt)
                                                .font(.subheadline)
                                            Text("\(item.main.temp) K")
                                            Text("\(item.main.feels_like) K")
                                            Text("\(item.clouds.all)%")
                                            Text("\(item.weather.first?.description ?? "")")
                                        }
                                        .padding()
                                        .background(Color.orange.opacity(0.1))
                                        .cornerRadius(8)
                                        .frame(width: 150) // Ustal szerokość karty
                                    }
                                }
                            }
                            
                            
                        }
                        .padding()
                    
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
