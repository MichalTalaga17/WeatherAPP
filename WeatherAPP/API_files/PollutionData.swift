import Foundation

struct PollutionData: Codable {
    let list: [PollutionEntry]
}


struct PollutionEntry: Codable {
    let main: MainPollution
}

struct MainPollution: Codable {
    let aqi: Int
}

