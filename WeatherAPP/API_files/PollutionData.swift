import Foundation

struct PollutionData: Codable {
    let coord: Coordinates
    let list: [PollutionEntry]
    
    struct Coordinates: Codable {
        let lon: Double
        let lat: Double
        
        enum CodingKeys: String, CodingKey {
            case lon = "coord"
            case lat
        }
    }
    
    struct PollutionEntry: Codable {
        let dt: Int
        let main: Main
        let components: Components
        
        struct Main: Codable {
            let aqi: Int
        }
        
        struct Components: Codable {
            let co: Double
            let no: Double
            let no2: Double
            let o3: Double
            let so2: Double
            let pm2_5: Double
            let pm10: Double
            let nh3: Double
        }
    }
}
