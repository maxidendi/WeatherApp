//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Денис Максимов on 12.05.2025.
//

import Foundation

final class WeatherService {
    
    static let shared = WeatherService()
    
    private init() {}

    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let location = "\(lat),\(lon)"
        let urlString = "\(Constants.baseURLString)/forecast.json?key=\(Constants.apiKey)&q=\(location)&days=7"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 2)))
                return
            }

            do {
                let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(.success(weather))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
