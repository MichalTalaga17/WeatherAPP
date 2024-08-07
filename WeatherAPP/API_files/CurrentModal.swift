import Foundation

struct CurrentResponse: Codable {
    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct Main: Codable {
        let temp: Double
        let feels_like: Double
        let temp_min: Double
        let temp_max: Double
        let pressure: Int
        let humidity: Int
        let sea_level: Int
        let grnd_level: Int
    }
    
    struct Wind: Codable {
        let speed: Double
        let deg: Int
    }
    
    struct Clouds: Codable {
        let all: Int
    }
    
    struct Sys: Codable {
        let type: Int
        let id: Int
        let country: String
        let sunrise: Int
        let sunset: Int
    }
    
    struct Coord: Codable {
        let lon: Double
        let lat: Double
    }
    
    struct Rain: Codable {
        let hour1: Double?
        let hour3: Double?
        
        private enum CodingKeys: String, CodingKey {
            case hour1 = "1h"
            case hour3 = "3h"
        }
    }
    
    struct Snow: Codable {
        let hour1: Double?
        let hour3: Double?
        
        private enum CodingKeys: String, CodingKey {
            case hour1 = "1h"
            case hour3 = "3h"
        }
    }
    
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
    let rain: Rain?
    let snow: Snow?
}
