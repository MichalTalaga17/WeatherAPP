import SwiftUI

struct ContentView: View {
    @State private var cityName = "Zembrzyce"
    @State private var weatherData: WeatherData?
    var body: some View {
        NavigationView{
            VStack(alignment: .leading) {
                HStack {
                        HStack(spacing: 10) {
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
                Spacer()
                Spacer()
                Spacer()
                if let weatherData = weatherData, let currentWeather = weatherData.list.first {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // City Information Block
                        HStack {
                            VStack(alignment: .leading, spacing: 5){
                                Text(kelvinToCelsius(currentWeather.main.temp))
                                    .font(.largeTitle .bold())
                            }
                            .padding()
                            Spacer()
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(weatherData.city.name)")
                                    .font(.title2 .bold())
                                Text("Wschód słońca: \(formatDate(timestamp: weatherData.city.sunrise, formatType: .timeOnly))")
                                Text("Zachód słońca: \(formatDate(timestamp: weatherData.city.sunset, formatType: .timeOnly))")
                            }
                            .padding()
                            
                        }
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                        
                        // Current Weather Block
                        if let currentWeather = weatherData.list.first {
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
                            
                        }
                        
                        // Weather Forecast Block
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 10) { // Odstęp między kartami
                                ForEach(weatherData.list.prefix(10), id: \.dt) { item in
                                    VStack(alignment: .leading, spacing: 10) {
                                        if let timestamp = dateToTimestamp(dateString: item.dt_txt) {
                                            Text(formatDate(timestamp: Int(timestamp), formatType: .timeOnly))
                                                .font(.subheadline)
                                        } else {
                                            Text(item.dt_txt)
                                                .font(.subheadline)
                                        }
                                        Text(kelvinToCelsius(item.main.temp))
                                            .font(.title2 .bold())
                                        Text(kelvinToCelsius(item.main.feels_like))
                                            .font(.body)
                                        Text("\(item.clouds.all)%")
                                            .font(.body)
                                        Text("\(item.weather.first?.icon ?? "")")
                                            .font(.body)
                                    }
                                    .padding()
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                                    .frame(maxWidth: .infinity) // Pozwól, aby karta zajmowała dostępne miejsce
                                    .layoutPriority(1) // Zwiększa priorytet dla szerokości karty
                                    .frame(width: UIScreen.main.bounds.width * 0.3) // Ustaw szerokość karty na 30% szerokości ekranu
                                }
                            }
                        }
                        Spacer()
                        
                        
                    }
                    
                }  else{
                    HStack{}
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Pogoda")
            Spacer()
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
    
    
}

#Preview {
    ContentView()
}
