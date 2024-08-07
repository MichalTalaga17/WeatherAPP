import SwiftUI
import SwiftData
import Foundation

struct CityRowView: View {
    @Environment(\.modelContext) private var modelContext
    @State var city: City

    var body: some View {
        NavigationLink(destination: LocationWeatherView(cityName: city.name, favourite: true)) {
            HStack {
                Text(city.name)
                Spacer()
                if let temperature = city.temperature {
                    Text(kelvinToCelsius(temperature))
                }
                if let icon = city.weatherIcon {
                    weatherIcon(for: icon)
                }
            }
        }
        .task {
            await fetchWeatherData(for: city)
        }
    }
    
    func fetchWeatherData(for city: City) async {
        await fetchCurrentWeatherData(forCity: city) { _ in }
    }
}