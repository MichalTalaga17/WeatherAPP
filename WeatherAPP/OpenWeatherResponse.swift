import Foundation

// Odpowiedź z API dla prognozy
struct OpenWeatherForecastResponse: Codable {
    let list: [WeatherForecast]
}

struct WeatherForecast: Codable, Identifiable {
    var id = UUID()
    let dt: Int
    let main: Main
    let weather: [WeatherDetails]
    
    // Konwersja daty
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(dt))
    }
}

struct Main: Codable {
    let temp: Double
}

struct WeatherDetails: Codable {
    let description: String
}

// Użyj tylko jednej struktury dla pogody obecnej
struct Weather: Codable {
    let temperature: Double
    let condition: String
}

// Model prognozy do wyświetlania
struct DailyForecast: Identifiable {
    let id = UUID()
    let date: Date
    let temperature: Double
    let condition: String
}

// Struktury dla odpowiedzi JSON

struct OpenWeatherCurrentResponse: Codable {
    let main: Main
    let weather: [WeatherDetails]

    struct Main: Codable {
        let temp: Double
    }

    struct WeatherDetails: Codable {
        let description: String
    }
}
