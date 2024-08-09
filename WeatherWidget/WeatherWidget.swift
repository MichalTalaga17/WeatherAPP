import WidgetKit
import SwiftUI
import Foundation

// Model danych do wyświetlania w widżecie
struct SimpleEntry: TimelineEntry {
    let date: Date
    let city: String
    let temperature: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let windSpeed: Double
    let windDirection: Int
    let cloudiness: Int
    let visibility: Int
    let sunrise: Date
    let sunset: Date
    let icon: String
}

// Provider dostarcza dane dla widżetu
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            city: "Miasto",
            temperature: 20.0,
            feelsLike: 18.0,
            tempMin: 15.0,
            tempMax: 22.0,
            pressure: 1013,
            humidity: 70,
            windSpeed: 5.0,
            windDirection: 180,
            cloudiness: 40,
            visibility: 10000,
            sunrise: Date(),
            sunset: Date(),
            icon: "01d"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            city: "Warszawa",
            temperature: 18.0,
            feelsLike: 17.0,
            tempMin: 15.0,
            tempMax: 21.0,
            pressure: 1012,
            humidity: 65,
            windSpeed: 4.0,
            windDirection: 200,
            cloudiness: 30,
            visibility: 10000,
            sunrise: Date(),
            sunset: Date(),
            icon: "01d"
        )
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
                        feelsLike: data.main.feels_like,
                        tempMin: data.main.temp_min,
                        tempMax: data.main.temp_max,
                        pressure: data.main.pressure,
                        humidity: data.main.humidity,
                        windSpeed: data.wind.speed,
                        windDirection: data.wind.deg,
                        cloudiness: data.clouds.all,
                        visibility: data.visibility,
                        sunrise: Date(timeIntervalSince1970: TimeInterval(data.sys.sunrise)),
                        sunset: Date(timeIntervalSince1970: TimeInterval(data.sys.sunset)),
                        icon: data.weather.first?.icon ?? "01d"
                    )
                    entries.append(entry)
                    
                    // Dodaj kolejne wpisy dla przyszłych odświeżeń
                    let nextUpdateDate = Calendar.current.date(byAdding: .second, value: 10, to: now)!
                    let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
                    completion(timeline)
                case .failure(let error):
                    print("Błąd pobierania danych o pogodzie: \(error.localizedDescription)")
                    
                    // W przypadku błędu użyj domyślnych danych
                    let entry = SimpleEntry(
                        date: now,
                        city: "Nieznane",
                        temperature: 0.0,
                        feelsLike: 0.0,
                        tempMin: 0.0,
                        tempMax: 0.0,
                        pressure: 0,
                        humidity: 0,
                        windSpeed: 0.0,
                        windDirection: 0,
                        cloudiness: 0,
                        visibility: 0,
                        sunrise: Date(),
                        sunset: Date(),
                        icon: "01d"
                    )
                    entries.append(entry)
                    
                    let timeline = Timeline(entries: entries, policy: .after(updateDate))
                    completion(timeline)
                }
            }
        } else {
            // Użyj domyślnych danych
            let entry = SimpleEntry(
                date: now,
                city: "Nieznane",
                temperature: 0.0,
                feelsLike: 0.0,
                tempMin: 0.0,
                tempMax: 0.0,
                pressure: 0,
                humidity: 0,
                windSpeed: 0.0,
                windDirection: 0,
                cloudiness: 0,
                visibility: 0,
                sunrise: Date(),
                sunset: Date(),
                icon: "01d"
            )
            entries.append(entry)
            
            let timeline = Timeline(entries: entries, policy: .after(updateDate))
            completion(timeline)
        }
    }
}

// Widok dla małego widżetu (systemSmall)
struct WeatherWidgetEntryView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Text("\(entry.city) \(Int(entry.temperature))°")
                .font(.subheadline)
            HStack (alignment: .center) {
                Spacer()
                weatherIcon(for: entry.icon)
                Spacer()
            }
        }
        .padding(.vertical)
        .cornerRadius(8)
        .foregroundColor(.white)
        .containerBackground(for: .widget) {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            Color.black.opacity(0.3)
        }
    }
}

// Widok dla średniego widżetu (systemMedium)
struct WeatherWidgetMediumEntryView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(entry.city)")
                    .font(.headline)
                    .bold()
                Spacer()
                Text("\(Int(entry.temperature))°C")
                    .font(.largeTitle)
            }
            
            HStack(spacing: 15) {
                HStack {
                    Image(systemName: "thermometer")
                    Text("Feels like: \(Int(entry.feelsLike))°C")
                }
                
                HStack {
                    Image(systemName: "drop.fill")
                    Text("Humidity: \(entry.humidity)%")
                }
            }
            
            HStack(spacing: 15) {
                HStack {
                    Image(systemName: "wind")
                    Text("Wind: \(Int(entry.windSpeed)) m/s")
                }
                
                HStack {
                    Image(systemName: "cloud")
                    Text("Clouds: \(entry.cloudiness)%")
                }
            }
            
            HStack(spacing: 15) {
                HStack {
                    Image(systemName: "eye")
                    Text("Visibility: \(entry.visibility / 1000) km")
                }
                
                HStack {
                    Image(systemName: "gauge")
                    Text("Pressure: \(entry.pressure) hPa")
                }
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            Color.black.opacity(0.3)
        }
        .cornerRadius(10)
        .foregroundColor(.white)
    }
}

// Konfiguracja małego widżetu (systemSmall)
struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Small Weather Widget")
        .description("Shows basic weather information.")
        .supportedFamilies([.systemSmall])
    }
}

// Konfiguracja średniego widżetu (systemMedium)
struct WeatherWidgetMedium: Widget {
    let kind: String = "WeatherWidgetMedium"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetMediumEntryView(entry: entry)
        }
        .configurationDisplayName("Medium Weather Widget")
        .description("Shows more detailed weather information.")
        .supportedFamilies([.systemMedium])
    }
}



// Funkcja do pobierania danych pogodowych z API
func fetchCurrentWeatherData(forCity city: String, completion: @escaping (Result<CurrentResponse, Error>) -> Void) {
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
            let simpleWeatherData = try JSONDecoder().decode(CurrentResponse.self, from: data)
            DispatchQueue.main.async {
                completion(.success(simpleWeatherData))
            }
        } catch {
            completion(.failure(error))
        }
        
    }.resume()
}

// Preview widżetów
#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        city: "Zembrzyce",
        temperature: 20.0,
        feelsLike: 18.0,
        tempMin: 15.0,
        tempMax: 22.0,
        pressure: 1013,
        humidity: 70,
        windSpeed: 5.0,
        windDirection: 180,
        cloudiness: 40,
        visibility: 10000,
        sunrise: Date(),
        sunset: Date(),
        icon: "01d"
    )
}

#Preview(as: .systemMedium) {
    WeatherWidgetMedium()
} timeline: {
    SimpleEntry(
        date: .now,
        city: "Zembrzyce",
        temperature: 20.0,
        feelsLike: 18.0,
        tempMin: 15.0,
        tempMax: 22.0,
        pressure: 1013,
        humidity: 70,
        windSpeed: 5.0,
        windDirection: 180,
        cloudiness: 40,
        visibility: 10000,
        sunrise: Date(),
        sunset: Date(),
        icon: "01d"
    )
}
