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
    
    private var weatherData: WeatherResponse? {
        didSet {
            updateUI()
        }
    }
    private var forecastDaily: [ForecastDay] {
        guard let weatherData else { return [] }
        return weatherData.forecast.forecastday
    }
    private var hourlyForecast: [HourForecast] {
        guard let weatherData else { return [] }
        let hours = weatherData.forecast.forecastday.flatMap { $0.hour }
        return hours.filter { String.isDateInRange($0.time) }
    }
    private let locationManager = CLLocationManager()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = true
        return scrollView
    } ()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    } ()
    
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
    
    private let hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemGray.withAlphaComponent(0.5)
        collectionView.layer.cornerRadius = 8
        return collectionView
    }()

    private let dailyTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.backgroundColor = .systemGray.withAlphaComponent(0.5)
        tableView.layer.cornerRadius = 8
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()

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
        setupScrollView()
        setupHeader()
        setupCollectionView()
        setupTableView()
    }
    
    private func setupScrollView() {
        [scrollView, contentView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupHeader() {
        [locationLabel, tempLabel, conditionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            locationLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            tempLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tempLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
            
            conditionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            conditionLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 16),
        ])
    }
    
    private func setupCollectionView() {
        hourlyCollectionView.dataSource = self
        hourlyCollectionView.delegate = self
        hourlyCollectionView.register(HourlyForecastCell.self, forCellWithReuseIdentifier: HourlyForecastCell.identifier)
        contentView.addSubview(hourlyCollectionView)
        NSLayoutConstraint.activate([
            hourlyCollectionView.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: 16),
            hourlyCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            hourlyCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            hourlyCollectionView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    private func setupTableView() {
        dailyTableView.dataSource = self
        dailyTableView.delegate = self
        dailyTableView.register(DailyForecastCell.self, forCellReuseIdentifier: DailyForecastCell.identifier)
        contentView.addSubview(dailyTableView)
        NSLayoutConstraint.activate([
            dailyTableView.topAnchor.constraint(equalTo: hourlyCollectionView.bottomAnchor, constant: 16),
            dailyTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            dailyTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            dailyTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dailyTableView.heightAnchor.constraint(equalToConstant: 350)
        ])
    }

    private func fetchWeather(lat: Double = 55.752, lon: Double = 37.616) {
        activityIndicator.startAnimating()

        WeatherService.shared.fetchWeather(lat: lat, lon: lon) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let data):
                    self?.weatherData = data
                case .failure:
                    self?.showErrorAlert()
                }
            }
        }
    }

    private func updateUI() {
        locationLabel.text = weatherData?.location.name
        tempLabel.text = "\(weatherData?.current.temp_c ?? 0)℃"
        conditionLabel.text = weatherData?.current.condition.text
        hourlyCollectionView.reloadData()
        dailyTableView.reloadData()
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

extension WeatherViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyForecast.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "HourlyForecastCell",
            for: indexPath) as? HourlyForecastCell
        else { return UICollectionViewCell() }
        cell.configure(with: hourlyForecast[safe: indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 100)
    }
}

extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "DailyForecastCell",
            for: indexPath) as? DailyForecastCell
        else { return UITableViewCell() }
        cell.configure(with: forecastDaily[safe: indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
