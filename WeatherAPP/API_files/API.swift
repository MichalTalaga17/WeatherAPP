import Foundation

class API {
    static let key = "e58dfbc15daacbeabeed6abc3e5d95ca"
    static let shared = API()
    
    // Metoda do pobierania danych prognozy pogody
    func fetchForecastData(forCity city: String, completion: @escaping (Result<ForecastData, Error>) -> Void) {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(encodedCity)&appid=\(API.key)"
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
    
    // Metoda do pobierania bieżących danych pogodowych
    func fetchCurrentWeatherData(forCity city: String, completion: @escaping (Result<CurrentResponse, Error>) -> Void) {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(API.key)&units=metric"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let simpleWeatherData = try JSONDecoder().decode(CurrentResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(simpleWeatherData))
                }
            } catch {
                completion(.failure(error))
            }
            
        }.resume()
    }
    
    func fetchAirPollutionData(forCity city: String, completion: @escaping (Result<PollutionData, Error>) -> Void) {
        fetchCurrentWeatherData(forCity: city) { result in
            switch result {
            case .success(let weatherData):
                let latitude = weatherData.coord.lat
                let longitude = weatherData.coord.lon
                
                let urlString = "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(latitude)&lon=\(longitude)&appid=\(API.key)"
                print(urlString)
                guard let url = URL(string: urlString) else {
                    completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
                    return
                }
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let data = data else {
                        completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                        return
                    }
                    
                    do {
                        // Dekodujemy dane odpowiedzi do struktury PollutionData
                        let pollutionData = try JSONDecoder().decode(PollutionData.self, from: data)
                        DispatchQueue.main.async {
                            completion(.success(pollutionData))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                    
                }.resume()
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
