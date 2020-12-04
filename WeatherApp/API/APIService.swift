//
//  APIService.swift
//  WeatherApp
//
//  Created by Adam Wienconek on 04/12/2020.
//

import Foundation

class APIService {
    public static var countryCode = "us"
    
    public static let apiKey = "55a2f0818eb44fcc1ae2c03616fdddb2"
    
    private var dataTask: URLSessionDataTask? {
        didSet {
            dataTask?.resume()
        }
    }
    
    private var history: Set<City> {
        didSet {
            storeCities()
        }
    }
    
    init() {
        guard let data = UserDefaults.standard.data(forKey: "history"),
              let cities = try? JSONDecoder().decode(Set<City>.self, from: data) else {
            history = []
            return
        }
        history = cities
    }
    
    func getWeather(for zipCode: String, completion: @escaping (Result<Weather, Error>) -> Void) {
        let zipParam = "\(zipCode),\(Self.countryCode)"
        let params = [
            "zip": zipParam
        ]
        guard let request = Method.current.request(with: params) else {
            completion(.failure(APIError.invalidUrl))
            return
        }
        
        dataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, requestError in
            if let error = requestError {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(APIError.statusCode))
                return
            }
            guard let data = data, !data.isEmpty else {
                completion(.failure(APIError.noData))
                return
            }
            do {
                let weather = try JSONDecoder().decode(Weather.self, from: data)
                self.history.insert(weather.city)
                completion(.success(weather))
            } catch let error {
                completion(.failure(error))
            }
        })
    }
    
    func getForecast(for coordinates: Coordinate, completion: @escaping (Result<LocalForecast, Error>) -> Void) {
        let params = [
            "lat": String(coordinates.latitude),
            "lon": String(coordinates.longitude),
            "exclude": ["minutely", "daily", "alerts"].joined(separator: ",")
        ]
        guard let request = Method.forecast.request(with: params) else {
            completion(.failure(APIError.invalidUrl))
            return
        }
        
        dataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, requestError in
            if let error = requestError {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(APIError.statusCode))
                return
            }
            guard let data = data, !data.isEmpty else {
                completion(.failure(APIError.noData))
                return
            }
            do {
                let forecast = try JSONDecoder().decode(LocalForecast.self, from: data)
                completion(.success(forecast))
            } catch let error {
                completion(.failure(error))
            }
        })
    }
    
    func searchedCitiesWeather(completion: @escaping ([City: WeatherForecast]) -> Void) {
        let group = DispatchGroup()
        
        var weathers = [City: WeatherForecast]()
        for city in history {
            group.enter()
            getForecast(for: city.coordinate) { result in
                switch result {
                case .success(let forecast):
                    weathers[city] = forecast.current
                case .failure(let error):
                    print(error.localizedDescription)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(weathers)
        }
    }
    
    private func storeCities() {
        guard let data = try? JSONEncoder().encode(history) else {
            return
        }
        UserDefaults.standard.setValue(data, forKey: "history")
    }
    
    private enum Method: String, APIMethod {
        case current
        case forecast
        
        var path: String {
            switch self {
            case .current:
                return "weather"
            case .forecast:
                return "onecall"
            }
        }
    }
}
