import Foundation

struct PollutionData: Codable {
    let list: [PollutionEntry]
}

struct PollutionEntry: Codable {
    let main: MainPollution
    let components: PollutionComponents
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
