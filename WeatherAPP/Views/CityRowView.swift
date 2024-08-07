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
                    Text("\(String(format: "%.1f", temperature))°C")
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
        do {
            try await fetchCurrentWeatherData(forCity: city) { result in
                switch result {
                case .success(let data):
                    print("Fetched data for \(city.name): \(data)")
                case .failure(let error):
                    // Handle error here if needed
                    print("Error fetching data for \(city.name): \(error)")
                }
            }
        } catch {
            print("Error fetching data for \(city.name): \(error.localizedDescription)")
        }
    }
}
