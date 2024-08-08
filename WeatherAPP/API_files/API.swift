import Foundation

class API {
    static let shared = API()
    
    func fetchForecastData(forCity city: String, completion: @escaping (Result<ForecastData, Error>) -> Void) {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(encodedCity)&lang=pl&appid=e58dfbc15daacbeabeed6abc3e5d95ca"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            
            do {
                let forecastData = try JSONDecoder().decode(ForecastData.self, from: data)
                completion(.success(forecastData))
            } catch {
                print("Decoding forecast error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchCurrentWeatherData(forCity city: String, completion: @escaping (Result<CurrentResponse, Error>) -> Void) {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&lang=pl&appid=e58dfbc15daacbeabeed6abc3e5d95ca"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: [NSLocalizedDescriptionKey: "The URL is malformed."])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network error occurred: \(error.localizedDescription)"])))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "InvalidResponse", code: -1, userInfo: [NSLocalizedDescriptionKey: "The response is not an HTTP response."])))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                print(errorMessage)
                completion(.failure(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from server."])))
                return
            }
            
            
            do {
                let currentWeatherData = try JSONDecoder().decode(CurrentResponse.self, from: data)
                completion(.success(currentWeatherData))
                
                print(currentWeatherData)
            } catch {
                print("JSON decoding error: \(error.localizedDescription)")
                completion(.failure(NSError(domain: "JSONDecodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON data: \(error.localizedDescription)"])))
            }
        }.resume()
    }
    
}
