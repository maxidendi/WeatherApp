//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Денис Максимов on 12.05.2025.
//

import Foundation

protocol WeatherServiceProtocol {
    func fetchWeather(lat: Double, long: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void)
}

final class WeatherService: WeatherServiceProtocol {

    func fetchWeather(lat: Double, long: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let fulfillCompletionOnMainThread: (Result<WeatherResponse, Error>) -> Void = { result in
            DispatchQueue.main.async{
                completion(result)
            }
        }
        guard let url = getWeatherUrl(lat: lat, long: long) else {
            fulfillCompletionOnMainThread(.failure(NSError(domain: "Invalid URL", code: 1)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                fulfillCompletionOnMainThread(.failure(error))
                return
            }

            guard let data else {
                fulfillCompletionOnMainThread(.failure(NSError(domain: "No data", code: 2)))
                return
            }

            do {
                let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
                fulfillCompletionOnMainThread(.success(weather))
            } catch {
                fulfillCompletionOnMainThread(.failure(error))
            }
        }.resume()
    }
    
    private func getWeatherUrl(lat: Double, long: Double) -> URL? {
        var urlComponents = URLComponents(
            string: Constants.baseURLString + "/forecast.json"
        )
        urlComponents?.queryItems = [
            URLQueryItem(name: "key", value: Constants.apiKey),
            URLQueryItem(name: "q", value: "\(lat),\(long)"),
            URLQueryItem(name: "days", value: String(Constants.forecastDaysCount)),
            URLQueryItem(name: "lang", value: "ru"),
        ]
        return urlComponents?.url
    }
}
