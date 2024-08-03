import Foundation
import CoreLocation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weather: Weather?
    @Published var dailyForecasts: [WeatherForecast] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let apiKey = "e58dfbc15daacbeabeed6abc3e5d95ca" // Replace with your actual API key

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
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                errorMessage = "Server error"
                isLoading = false
                return
            }

            let decoder = JSONDecoder() // Create a single decoder instance for efficiency

            let weatherResponse = try decoder.decode(OpenWeatherForecastResponse.self, from: data)

            // Process weather data efficiently
            self.weather = weatherResponse.list.first.map {
                Weather(temperature: $0.main.temp, condition: $0.weather.first?.description ?? "")
            }

            // Filter and sort daily forecasts (optimized with lazy evaluation)
            self.dailyForecasts = weatherResponse.list
                .lazy // Defer processing until necessary
                .filter { Calendar.current.component(.hour, from: $0.date) == 12 } // Filter for 12:00 (adjust as needed)
                .prefix(5) // Limit to 5 forecasts
                .sorted { $0.date < $1.date } // Sort by date

        } catch {
            errorMessage = "Failed to fetch weather data: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

