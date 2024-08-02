import SwiftUI
import CoreLocation

struct WeatherView: View {
    @StateObject private var weatherViewModel = WeatherViewModel()
    let location: CLLocation

    private var formattedLatitude: String {
        String(format: "%.4f", location.coordinate.latitude)
    }

    private var formattedLongitude: String {
        String(format: "%.4f", location.coordinate.longitude)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Location Details")
                .font(.title)
                .bold()

            Text("Latitude: \(formattedLatitude)")
            Text("Longitude: \(formattedLongitude)")

            if weatherViewModel.isLoading {
                ProgressView()
            } else if let weather = weatherViewModel.weather {
                Text("Current Temperature: \(weather.temperature)°C")
                Text("Current Weather: \(weather.condition)")

                // Wyświetlanie prognozy na 5 dni
                List(weatherViewModel.dailyForecasts) { forecast in
                    VStack(alignment: .leading) {
                        Text(forecast.date, style: .date)
                        Text("Temperature: \(forecast.main.temp, specifier: "%.1f")°C")
                        Text("Weather: \(forecast.weather.first?.description.capitalized ?? "N/A")")
                    }
                }
            } else if let errorMessage = weatherViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                Text("No weather data available")
            }

            Spacer()
        }
        .onAppear {
            Task {
                await weatherViewModel.fetchWeather(for: location)
            }
        }
        .padding()
        .navigationTitle("Weather Details")
    }
}

#Preview {
    WeatherView(location: CLLocation(latitude: 37.7749, longitude: -122.4194))
}
