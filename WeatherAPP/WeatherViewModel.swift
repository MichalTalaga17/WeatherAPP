import Foundation
import CoreLocation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weather: Weather?
    @Published var dailyForecasts: [WeatherForecast] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let apiKey = "e58dfbc15daacbeabeed6abc3e5d95ca"  // Zamień na swój klucz API
    
    func fetchWeather(for location: CLLocation) async {
        isLoading = true
        errorMessage = nil
        
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                errorMessage = "Server error: \(httpResponse.statusCode)"
                isLoading = false
                return
            }
            
            let weatherResponse = try JSONDecoder().decode(OpenWeatherForecastResponse.self, from: data)
            
            // Przetwarzanie danych do formatu widocznego
            self.weather = Weather(
                temperature: weatherResponse.list.first?.main.temp ?? 0.0,
                condition: weatherResponse.list.first?.weather.first?.description ?? ""
            )
            
            // Filtrujemy prognozy na każdy dzień
            let calendar = Calendar.current
            self.dailyForecasts = weatherResponse.list
                .filter { calendar.component(.hour, from: $0.date) == 12 }  // Przykładowo dla prognozy na 12:00
                .prefix(5)
                .sorted { $0.date < $1.date }
            
        } catch {
            self.errorMessage = "Failed to fetch weather data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}


