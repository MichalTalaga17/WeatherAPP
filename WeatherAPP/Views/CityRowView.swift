import SwiftUI
import SwiftData
import Foundation

struct CityRowView: View {
    @Environment(\.modelContext) private var modelContext
    @State var city: City

    var body: some View {
        NavigationLink(destination: LocationWeatherView(cityName: city.name, favourite: true)) {
            HStack(spacing: 5) {
                Text(city.name)
                    .font(.title2)
                Spacer()
                HStack{
                    if let temperature = city.temperature {
                        Text("\(Int(temperature))°")
                            .font(.title3)
                    }
                    if let icon = city.weatherIcon {
                        weatherIcon(for: icon)
                    }
                }
            }
        }
        .task {
            await fetchWeatherData(for: city)
        }
    }
    
    func fetchWeatherData(for city: City) async {
        API.shared.fetchCurrentWeatherData(forCity: city.name) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    city.temperature = data.main.temp
                    city.weatherIcon = data.weather.first?.icon
                }
            case .failure(let error):
                DispatchQueue.main.async {
                }
            }
        }
    }

}
