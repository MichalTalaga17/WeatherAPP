//
//  API.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import Foundation
import SwiftUI

class API {
    enum Units: String, Identifiable, CaseIterable {
        case metric = "metric"
        case imperial = "imperial"
        
        var id: String { self.rawValue }
    }

    @AppStorage("units") private var units: Units = .metric
    static let key = "e58dfbc15daacbeabeed6abc3e5d95ca"
    static let shared = API()
    
    // Metoda do pobierania danych prognozy pogody
    func fetchForecastData(forCity city: String, completion: @escaping (Result<ForecastData, Error>) -> Void) {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(encodedCity)&appid=\(API.key)&units=\(units)"
        print(urlString)

        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "Invalid URL", code: -1, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let error = NSError(domain: "HTTP Error", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "No data", code: -1, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            do {
                let forecastData = try JSONDecoder().decode(ForecastData.self, from: data)
                completion(.success(forecastData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Metoda do pobierania bieżących danych pogodowych
    func fetchCurrentWeatherData(forCity city: String, completion: @escaping (Result<CurrentData, Error>) -> Void) {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(API.key)&units=\(units)"
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
                let simpleWeatherData = try JSONDecoder().decode(CurrentData.self, from: data)
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
