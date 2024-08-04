import Foundation

class API {
    static let shared = API()

    func fetchWeatherData(forCity city: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&lang=pl&appid=e58dfbc15daacbeabeed6abc3e5d95ca"
        print(urlString)
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
            print(0)
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print(1)
                completion(.failure(error ?? NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            print("1.1\( data)")

            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                print(2)
                completion(.success(weatherData))
            } catch {
                completion(.failure(error))
                print(3)
            }
        }.resume()
        print(4)
    }
}
