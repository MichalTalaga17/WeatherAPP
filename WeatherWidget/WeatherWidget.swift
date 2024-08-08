import WidgetKit
import SwiftUI
import Foundation

// Model danych do wyświetlania w widżecie
struct SimpleEntry: TimelineEntry {
    let date: Date
    let city: String
    let temperature: Double
    let icon: String
}

// Provider dostarcza dane dla widżetu
struct Provider: TimelineProvider {
    // Placeholder pokazuje przykładowe dane podczas ładowania widżetu
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), city: "Miasto", temperature: 20.0, icon: "01d")
    }
    
    // Snapshot pokazuje dane w galerii widżetów
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), city: "Warszawa", temperature: 18.0, icon: "01d")
        completion(entry)
    }
    
    // Timeline generuje rzeczywiste dane do wyświetlenia w widżecie
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []

        if let userDefaults = UserDefaults(suiteName: "group.me.michaltalaga.WeatherAPP") {
            let city = userDefaults.string(forKey: "City") ?? "Nieznane"
            let temperature = userDefaults.double(forKey: "Temperature")
            let icon = userDefaults.string(forKey: "Icon") ?? "01d"

            let entry = SimpleEntry(date: .now, city: city, temperature: temperature, icon: icon)
            entries.append(entry)
        } else {
            let entry = SimpleEntry(date: .now, city: "Domyślne Miasto", temperature: 0.0, icon: "01d")
            entries.append(entry)
        }

        // Zwrócenie całego harmonogramu za pomocą completion
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// Widok widżetu
struct WeatherWidgetEntryView: View {
    var entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.city)
                .font(.headline)
                .task {
                    fetchCurrentWeatherData(forCity: entry.city) { result in
                        switch result {
                        case .success(let weather):
                            // Aktualizacja widoku z użyciem pobranych danych pogodowych
                            print("Temperature: \(weather.main.temp)")
                            print("Icon: \(weather.weather.first?.icon ?? "BRAK")")
                        case .failure(let error):
                            // Obsługa błędu
                            print("Error fetching weather data: \(error.localizedDescription)")
                        }
                    }
                }
            Spacer()
            HStack {
                Text("\(Int(entry.temperature))°C")
                    .font(.title)
                
                Text(entry.icon)
                    .font(.title)
            }
        }
        .padding()
        .background(Color.red.opacity(0.2))
        .cornerRadius(8)
        .containerBackground(for: .widget) {
            Color.red.opacity(0.2)
        }
    }
}

// Konfiguracja widżetu
struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Widget Pogody")
        .description("Wyświetla aktualne informacje o pogodzie.")
    }
}

// Model dla danych pogodowych
struct SimpleWeather: Codable {
    struct Weather: Codable {
        let icon: String
    }
    
    struct Main: Codable {
        let temp: Double
    }
    
    let weather: [Weather]
    let main: Main
    let name: String
}

// Funkcja do pobierania danych pogodowych z API
func fetchCurrentWeatherData(forCity city: String, completion: @escaping (Result<SimpleWeather, Error>) -> Void) {
    let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&lang=pl&appid=e58dfbc15daacbeabeed6abc3e5d95ca&units=metric"
    
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: [NSLocalizedDescriptionKey: "The URL is malformed."])))
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Network error: \(error.localizedDescription)")
            completion(.failure(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network error occurred: \(error.localizedDescription)"])))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(NSError(domain: "InvalidResponse", code: -1, userInfo: [NSLocalizedDescriptionKey: "The response is not an HTTP response."])))
            return
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = "HTTP Error: \(httpResponse.statusCode)"
            print(errorMessage)
            completion(.failure(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "NoData", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from server."])))
            return
        }
        
        do {
            let weatherResponse = try JSONDecoder().decode(SimpleWeather.self, from: data)
            completion(.success(weatherResponse))
        } catch {
            print("JSON decoding error: \(error.localizedDescription)")
            completion(.failure(NSError(domain: "JSONDecodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON data: \(error.localizedDescription)"])))
        }
    }.resume()
}

// Preview widżetu
#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    SimpleEntry(date: .now, city: "Zembrzyce", temperature: 20.0, icon: "01d")
}
