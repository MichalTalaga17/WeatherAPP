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
                        do {
                            let weatherData: () = try await API.shared.fetchWeatherData(forCity: cityName) { result in
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


                if let weatherData = weatherData {
                    Text("Temperatura obecnie: \(String(describing: weatherData.list.first!.main.temp)) K")
                    Text("Odczuwalna temperatura: \(String(describing: weatherData.list.first!.main.feels_like)) K")
//                    Text("Pogoda obecnie: \(weatherData.weather.first?.description ?? "")")

//                    List(weatherData.daily) { daily in
//                        VStack(alignment: .leading) {
//                            Text("Dzień: \(formatDate(timestamp: daily.dt))")
//                            Text("Temperatura min: \(daily.temp.min) K")
//                            Text("Temperatura max: \(daily.temp.max) K")
//                            Text("Pogoda: \(daily.weather.first?.description ?? "")")
//                        }
//                    }
                }
            }
            .padding()
            .navigationTitle("Pogoda")
        }
    }

//    func fetchWeatherData() async {
//        do {
//            let weatherData = try await API.shared.fetchWeatherData(forCity: cityName)
//            self.weatherData = weatherData
//        } catch {
//            print("Błąd podczas pobierania danych: \(error)")
//        }
//    }

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
