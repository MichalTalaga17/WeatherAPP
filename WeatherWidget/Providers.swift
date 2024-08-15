import Foundation
import WidgetKit

// MARK: - ForecastProvider

struct ForecastProvider: TimelineProvider {
    func placeholder(in context: Context) -> ForecastEntry {
        ForecastEntry(
            date: Date(),
            forecast: [],
            timeZone: TimeZone.current,
            cityName: "Miasto"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ForecastEntry) -> ()) {
        fetchForecastData { result in
            switch result {
            case .success(let (forecast, timeZone, cityName)):
                let entry = ForecastEntry(date: Date(), forecast: forecast, timeZone: timeZone, cityName: cityName)
                completion(entry)
            case .failure:
                let entry = ForecastEntry(date: Date(), forecast: [], timeZone: TimeZone.current, cityName: "Nieznane")
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ForecastEntry>) -> ()) {
        fetchForecastData { result in
            switch result {
            case .success(let (forecast, timeZone, cityName)):
                let entry = ForecastEntry(date: Date(), forecast: forecast, timeZone: timeZone, cityName: cityName)
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            case .failure:
                let entry = ForecastEntry(date: Date(), forecast: [], timeZone: TimeZone.current, cityName: "Nieznane")
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            }
        }
    }
    
    private func fetchForecastData(completion: @escaping (Result<([ForecastItem], TimeZone, String), Error>) -> Void) {
        guard let userDefaults = UserDefaults(suiteName: "group.me.michaltalaga.WeatherAPP"),
              let cityName = userDefaults.string(forKey: "City") else {
            completion(.failure(NSError(domain: "No City Name Found", code: -1, userInfo: nil)))
            return
        }
        
        API.shared.fetchForecastData(forCity: cityName) { result in
            switch result {
            case .success(let data):
                let forecastItems = data.list.prefix(6).map { item in
                    ForecastItem(
                        time: Int(item.dt),
                        temperature: item.main.temp,
                        iconName: iconName(for: item.weather.first?.icon ?? "defaultIcon")
                    )
                }
                let timeZone = TimeZone(secondsFromGMT: data.city.timezone) ?? TimeZone.current
                completion(.success((forecastItems, timeZone, cityName)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func iconName(for icon: String) -> String {
        return iconMap[icon] ?? "questionmark"
    }
}

// MARK: - WeatherProvider

struct WeatherProvider: TimelineProvider {
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
        fetchWeatherData { result in
            switch result {
            case .success(let entry):
                completion(entry)
            case .failure:
                let entry = SimpleEntry(
                    date: Date(),
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
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        fetchWeatherData { result in
            switch result {
            case .success(let entry):
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            case .failure:
                let entry = SimpleEntry(
                    date: Date(),
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
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            }
        }
    }
    
    private func fetchWeatherData(completion: @escaping (Result<SimpleEntry, Error>) -> Void) {
        guard let userDefaults = UserDefaults(suiteName: "group.me.michaltalaga.WeatherAPP"),
              let cityName = userDefaults.string(forKey: "City") else {
            completion(.failure(NSError(domain: "No City Name Found", code: -1, userInfo: nil)))
            return
        }
        
        API.shared.fetchCurrentWeatherData(forCity: cityName) { result in
            switch result {
            case .success(let data):
                let entry = SimpleEntry(
                    date: Date(),
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
                    icon: iconName(for: data.weather.first?.icon ?? "01d")
                )
                completion(.success(entry))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func iconName(for icon: String) -> String {
        return iconMap[icon] ?? "questionmark"
    }
}

// MARK: - PollutionProvider

struct PollutionProvider: TimelineProvider {
    func placeholder(in context: Context) -> PollutionEntry2 {
        PollutionEntry2(
            date: Date(),
            pollution: sampleData,
            timeZone: TimeZone.current,
            cityName: "Miasto"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PollutionEntry2) -> ()) {
        fetchPollutionData { result in
            switch result {
            case .success(let (pollution, timeZone, cityName)):
                let entry = PollutionEntry2(date: Date(), pollution: pollution, timeZone: timeZone, cityName: cityName)
                completion(entry)
            case .failure:
                let entry = PollutionEntry2(date: Date(), pollution: emptyData, timeZone: TimeZone.current, cityName: "Nieznane")
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PollutionEntry2>) -> ()) {
        fetchPollutionData { result in
            switch result {
            case .success(let (pollution, timeZone, cityName)):
                let entry = PollutionEntry2(date: Date(), pollution: pollution, timeZone: timeZone, cityName: cityName)
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            case .failure:
                let entry = PollutionEntry2(date: Date(), pollution: emptyData, timeZone: TimeZone.current, cityName: "Nieznane")
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            }
        }
    }
    
    private func fetchPollutionData(completion: @escaping (Result<(PollutionData, TimeZone, String), Error>) -> Void) {
        guard let userDefaults = UserDefaults(suiteName: "group.me.michaltalaga.WeatherAPP"),
              let cityName = userDefaults.string(forKey: "City") else {
            completion(.failure(NSError(domain: "No City Name Found", code: -1, userInfo: nil)))
            return
        }
        
        API.shared.fetchAirPollutionData(forCity: cityName) { result in
            switch result {
            case .success(let data):
                let pollutionData = data
                let timeZone = TimeZone.current // Możesz dodać logikę do pobrania strefy czasowej, jeśli dane API to wspierają
                completion(.success((pollutionData, timeZone, cityName)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Przykładowe dane do placeholdera
    private var sampleData: PollutionData {
        PollutionData(
            list: [
                PollutionEntry(
                    main: MainPollution(aqi: 3),
                    components: PollutionComponents(
                        co: 0.5,
                        no: 0.02,
                        no2: 0.1,
                        o3: 0.3,
                        so2: 0.05,
                        pm2_5: 15.0,
                        pm10: 20.0,
                        nh3: 0.03
                    )
                )
            ]
        )
    }

    // Puste dane na wypadek błędu pobierania
    private var emptyData: PollutionData {
        PollutionData(list: [])
    }
}

