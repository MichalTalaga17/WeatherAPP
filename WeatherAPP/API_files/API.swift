import Foundation

class API {
    static let shared = API()

    func fetchForecastData(forCity city: String, completion: @escaping (Result<ForecastData, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&lang=pl&appid=e58dfbc15daacbeabeed6abc3e5d95ca"
        print(urlString)
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return()
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(.failure(error ?? NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            do {
                let forecastData = try JSONDecoder().decode(ForecastData.self, from: data)
                completion(.success(forecastData))
            } catch {
                completion(.failure(error))            }
        }.resume()
    }
    func fetchCurrentWeatherData(forCity city: String, completion: @escaping (Result<CurrentResponse, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&lang=pl&appid=e58dfbc15daacbeabeed6abc3e5d95ca"
        print(urlString)
                guard let url = URL(string: urlString) else {
                    completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
                    return
                }
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data else {
                        completion(.failure(error ?? NSError(domain: "No data", code: -1, userInfo: nil)))
                        return
                    }

                    do {
                        let currentWeatherData = try JSONDecoder().decode(CurrentResponse.self, from: data)
                        completion(.success(currentWeatherData))
                    } catch {
                        completion(.failure(error))
                    }
                }.resume()
            }
}


