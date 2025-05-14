//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Денис Максимов on 14.05.2025.
//

import Foundation
import CoreLocation

protocol WeatherViewModelProtocol: AnyObject {
    var onUpdateUI: ((WeatherResponse) -> Void)? { get set }
    var onShowIndicator: ((Bool) -> Void)? { get set }
    var onShowFetchError: (() -> Void)? { get set }
    
    func getDailyForecast() -> [DayForecast]
    func getHourlyForecast() -> [HourForecast]
    func checkLocationAuthorization()
}

final class WeatherViewModel: NSObject, WeatherViewModelProtocol {
    
    // MARK: - Properties
    
    var onUpdateUI: ((WeatherResponse) -> Void)?
    var onShowIndicator: ((Bool) -> Void)?
    var onShowFetchError: (() -> Void)?
    
    private var weatherData: WeatherResponse? {
        didSet {
            guard let weatherData else { return }
            onUpdateUI?(weatherData)
        }
    }
    private var dailyForecast: [DayForecast] {
        guard let weatherData else { return [] }
        return weatherData.forecast.forecastday
    }
    private var hourlyForecast: [HourForecast] {
        guard let weatherData else { return [] }
        let hours = weatherData.forecast.forecastday.flatMap { $0.hour }
        return hours.filter { String.isDateInRange($0.time) }
    }
    private let locationManager = CLLocationManager()
    
    // MARK: - Init
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }

    // MARK: - Methods
    
    func getDailyForecast() -> [DayForecast] {
        return dailyForecast
    }
    
    func getHourlyForecast() -> [HourForecast] {
        return hourlyForecast
    }
    
    func checkLocationAuthorization() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            fetchWeather()
        @unknown default:
            break
        }
    }

    private func fetchWeather(lat: Double = 55.752, lon: Double = 37.616) {
        onShowIndicator?(true)
        WeatherService.shared.fetchWeather(lat: lat, lon: lon) { [weak self] result in
            DispatchQueue.main.async {
                self?.onShowIndicator?(false)
                switch result {
                case .success(let data):
                    self?.weatherData = data
                case .failure:
                    self?.onShowFetchError?()
                }
            }
        }
    }
}

// MARK: - Extensions

extension WeatherViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations location: [CLLocation]) {
        guard let locValue = location.last else {
            return fetchWeather()
        }
        fetchWeather(lat: locValue.coordinate.latitude, lon: locValue.coordinate.longitude)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error updating location: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
