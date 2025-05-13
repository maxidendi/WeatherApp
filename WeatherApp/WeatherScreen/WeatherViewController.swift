//
//  ViewController.swift
//  WeatherApp
//
//  Created by Денис Максимов on 12.05.2025.
//

import UIKit
import CoreLocation

final class WeatherViewController: UIViewController {
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        return label
    } ()
    
    private lazy var tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 48, weight: .semibold)
        return label
    } ()
    
    private lazy var conditionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        return label
    } ()

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Methods of lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        setupUI()
        checkLocationAuthorization()
    }

    // MARK: - Methods
    
    private func checkLocationAuthorization() {
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
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка загрузки",
            message: nil,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "Повторить",
            style: .default
        ) { [weak self] _ in
            guard let self, let coordinates = self.locationManager.location?.coordinate else { return }
            fetchWeather(
                lat: coordinates.latitude,
                lon: coordinates.longitude)
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    private func setupUI() {
        [locationLabel, tempLabel, conditionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tempLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            
            conditionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            conditionLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 8),
        ])
    }

    private func fetchWeather(lat: Double = 55.752, lon: Double = 37.616) {
        activityIndicator.startAnimating()

        WeatherService.shared.fetchWeather(lat: lat, lon: lon) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let data):
                    self?.updateUI(with: data)
                case .failure:
                    self?.showErrorAlert()
                }
            }
        }
    }

    private func updateUI(with weatherData: WeatherResponse) {
        locationLabel.text = weatherData.location.name
        tempLabel.text = "\(weatherData.current.temp_c)℃"
        conditionLabel.text = weatherData.current.condition.text
    }
}

// MARK: - Extensions

extension WeatherViewController: CLLocationManagerDelegate {
    
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
