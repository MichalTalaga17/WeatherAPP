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
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), city: "Miasto", temperature: 20.0, icon: "01d")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), city: "Warszawa", temperature: 18.0, icon: "01d")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        let now = Date()
        let updateDate = Calendar.current.date(byAdding: .minute, value: 1, to: now)!

        if let userDefaults = UserDefaults(suiteName: "group.me.michaltalaga.WeatherAPP") {
            let city = userDefaults.string(forKey: "City") ?? "Nieznane"
            print(city)
            
            fetchCurrentWeatherData(forCity: city) { result in
                switch result {
                case .success(let data):
                    let entry = SimpleEntry(
                        date: now,
                        city: data.name,
                        temperature: data.main.temp,
                        icon: data.weather.first?.icon ?? "BRAK"
                    )
                    entries.append(entry)
                    
                    // Dodaj kolejne wpisy dla przyszłych odświeżeń
                    let nextUpdateDate = Calendar.current.date(byAdding: .second, value: 10, to: now)!
                    let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
                    completion(timeline)
                case .failure(let error):
                    print("Błąd pobierania danych o pogodzie: \(error.localizedDescription)")
                    
                    // W przypadku błędu użyj domyślnych danych
                    let entry = SimpleEntry(date: now, city: "Nieznane", temperature: 0.0, icon: "01d")
                    entries.append(entry)
                    
                    let timeline = Timeline(entries: entries, policy: .after(updateDate))
                    completion(timeline)
                }
            }
        } else {
            // Użyj domyślnych danych
            let entry = SimpleEntry(date: now, city: "Nieznane", temperature: 0.0, icon: "01d")
            entries.append(entry)
            
            let timeline = Timeline(entries: entries, policy: .after(updateDate))
            completion(timeline)
        }
    }
}

// Widok widżetu
struct WeatherWidgetEntryView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.city)
                .font(.headline)
            Spacer()
            HStack {
                Text("\(Int(entry.temperature))°C")
                    .font(.title)
                
                weatherIcon(for: entry.icon)
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
        completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
            return
        }
        
        do {
            let simpleWeatherData = try JSONDecoder().decode(SimpleWeather.self, from: data)
            DispatchQueue.main.async {
                completion(.success(simpleWeatherData))
            }
        } catch {
            completion(.failure(error))
        }
        
    }.resume()
}

// Preview widżetu
#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    SimpleEntry(date: .now, city: "Zembrzyce", temperature: 20.0, icon: "01d")
}
