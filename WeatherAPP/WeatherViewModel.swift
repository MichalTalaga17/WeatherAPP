import Foundation
import CoreLocation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weather: Weather?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let apiKey = "e58dfbc15daacbeabeed6abc3e5d95ca"  // Zamień na swój klucz API
    
    func fetchWeather(for location: CLLocation) async {
        isLoading = true
        errorMessage = nil
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let weatherResponse = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
            
            // Mapowanie odpowiedzi na nasz model `Weather`
            self.weather = Weather(
                temperature: weatherResponse.main.temp,
                condition: weatherResponse.weather.first?.description ?? "Unknown"
            )
        } catch {
            self.errorMessage = "Failed to fetch weather data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
