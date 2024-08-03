import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var cityName = ""
    @State private var weatherData: WeatherData?
    
    private let apiKey = "e58dfbc15daacbeabeed6abc3e5d95ca" // Zastąp swoim kluczem API OpenWeatherMap
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Podaj nazwę miasta", text: $cityName)
                
                Button("Szukaj") {
                    fetchWeatherData()
                }
                
                if let weatherData = weatherData {
                    Text("Pogoda w \(weatherData.name): \(weatherData.main.temp)°C")
                    Image(systemName: "cloud.sun.fill") // Przykładowa ikona, zastąp odpowiednią
                } else {
                    Text("Wprowadź nazwę miasta i kliknij Szukaj")
                }
            }
            .navigationTitle("Pogoda")
        }
    }
    
    struct WeatherData: Codable {
        let name: String
        let main: Main
    }
    
    struct Main: Codable {
        let temp: Double
    }
    
    func fetchWeatherData() {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(cityName) { placemarks, error in
            guard let placemark = placemarks?.first, let location = placemark.location else {
                print("Błąd podczas geokodowania lub pobierania lokalizacji")
                return
            }
            
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
            
            guard let url = URL(string: urlString) else {
                print("Nieprawidłowy URL")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    print("Błąd podczas pobierania danych")
                    return
                }
                
                do {
                    let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                    DispatchQueue.main.async {
                        self.weatherData = weatherData
                    }
                } catch {
                    print("Błąd podczas parsowania danych: \(error)")
                }
            }.resume()
        }
    }
}


#Preview{
    ContentView()
}
