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

struct ForecastData: Codable {
  let list: [Forecast]
  let city: City
}

struct City: Codable {
  let name: String
}

struct Forecast: Codable {
  let dt: Int // Date in seconds since epoch
  let main: Main
  let weather: [WeatherDescription]
  let dt_txt: String // Date and time in string format (ISO 8601)

  struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
  }

  struct WeatherDescription: Codable {
    let main: String
    let description: String

  }
}

struct DailyForecast: Identifiable {
  let id = UUID()
  let date: Date
  let temperature: Double
  let condition: String
}
struct Weather: Identifiable {
  let id = UUID()
  let city: String
  let temperature: Double
  let condition: String
}
