import Foundation

struct PollutionData: Codable {
    let coord: Coordinates
    let list: [PollutionEntry]
}

struct Coordinates: Codable {
    let lon: Double
    let lat: Double
}

struct PollutionEntry: Codable {
    let main: MainPollution
    let components: PollutionComponents
    let dt: Int
}

struct MainPollution: Codable {
    let aqi: Int
}

struct PollutionComponents: Codable {
    let co: Double
    let no: Double
    let no2: Double
    let o3: Double
    let so2: Double
    let pm2_5: Double
    let pm10: Double
    let nh3: Double
}
