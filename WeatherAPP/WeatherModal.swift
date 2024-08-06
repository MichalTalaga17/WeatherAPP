import Foundation

struct WeatherData: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [List]
    let city: City

    struct List: Codable {
        let dt: Int
        let main: Main
        let weather: [Weather]
        let clouds: Clouds
        let wind: Wind
        let visibility: Int
        let pop: Double
        let sys: Sys
        let dt_txt: String
        let rain: Rain?
        let snow: Snow?

        struct Main: Codable {
            let temp: Double
            let feels_like: Double
            let temp_min: Double
            let temp_max: Double
            let pressure: Int
            let sea_level: Int
            let grnd_level: Int
            let humidity: Int
            let temp_kf: Double
        }

        struct Weather: Codable {
            let id: Int
            let main: String
            let description: String
            let icon: String
        }

        struct Clouds: Codable {
            let all: Int
        }

        struct Wind: Codable {
            let speed: Double
            let deg: Int
            let gust: Double?
        }

        struct Sys: Codable {
            let pod: String
        }
        
        struct Rain: Codable {
            let h1: Double?
            let h3: Double?

            enum CodingKeys: String, CodingKey {
                case h1 = "1h"
                case h3 = "3h"
            }
        }
        
        struct Snow: Codable {
            let h1: Double?
            let h3: Double?

            enum CodingKeys: String, CodingKey {
                case h1 = "1h"
                case h3 = "3h"
            }
        }
    }

    struct City: Codable {
        let id: Int
        let name: String
        let coord: Coord
        let country: String
        let population: Int
        let timezone: Int
        let sunrise: Int
        let sunset: Int

        struct Coord: Codable {
            let lat: Double
            let lon: Double
        }
    }
}
