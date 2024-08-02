import Foundation
import CoreLocation
import WeatherKit

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weather: Weather?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let weatherService = WeatherService()
    
    func fetchWeather(for location: CLLocation) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let weatherData = try await weatherService.fetchWeather(for: location)
            self.weather = weatherData
        } catch {
            self.errorMessage = "Failed to fetch weather data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
