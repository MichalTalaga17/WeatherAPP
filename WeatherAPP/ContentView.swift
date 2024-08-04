import SwiftUI

struct ContentView: View {
    @State private var cityName = "Zembrzyce"
    @State private var weatherData: WeatherData?
    @State private var icon = "cloud.moon.rain.fill"
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
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
                                .background(Color.black.opacity(0.7))
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
                        .background(Color.blue.opacity(0.1))
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
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        
                        // Weather Forecast Block
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top) { // Odstęp między kartami
                                ForEach(weatherData.list.prefix(20), id: \.dt) { item in
                                    VStack(alignment: .leading) {
                                        if let timestamp = dateToTimestamp(dateString: item.dt_txt) {
                                            Text(formatDate(timestamp: Int(timestamp), formatType: .timeOnly))
                                                .font(.subheadline)
                                        } else {
                                            Text(item.dt_txt)
                                                .font(.subheadline)
                                        }
//                                        Image(systemName: icon)
//                                            .resizable()
//                                                .aspectRatio(contentMode: .fit) // Możesz również użyć .fill
//                                                .frame(width: 40, height: 40)
//                                                .symbolRenderingMode(.palette)
//                                                .foregroundStyle(.black, .gray, .blue)
                                        weatherIcon(for: (item.weather.first?.icon)!)
                                        Text(kelvinToCelsius(item.main.temp))
                                            .font(.title2.bold())
                                        Text(kelvinToCelsius(item.main.feels_like))
                                            .font(.body)
                                        Text("\(item.clouds.all)%")
                                            .font(.body)
//                                        Text("\(item.weather.first?.icon ?? "")")
//                                            .font(.body)
                                        
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.25) // Ustaw szerokość karty na 30% szerokości ekranu
                                }
                            }
                            .padding(.all)
                        }
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)// Pozwól, aby karta zajmowała dostępne miejsce
                        
                        Spacer()
                    }
                } else {
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Pogoda")
        }
        .foregroundColor(.white)
    }
    
    func fetchWeatherData() async {
        do {
            let cityNameCopy = cityName // Skopiuj wartość zmiennej
            let _: () = try await API.shared.fetchWeatherData(forCity: cityNameCopy) { result in
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
}

#Preview{
    ContentView()
}
