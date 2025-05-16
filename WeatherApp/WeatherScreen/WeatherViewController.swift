//
//  ViewController.swift
//  WeatherApp
//
//  Created by Денис Максимов on 12.05.2025.
//

import UIKit

final class WeatherViewController: UIViewController {
    
    // MARK: - Properties

    private let viewModel: WeatherViewModel
    private lazy var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.contentMode = .scaleAspectFill
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.systemCyan.cgColor, UIColor.systemMint.cgColor]
        gradient.locations = [0, 1]
        backgroundView.layer.insertSublayer(gradient, at: 0)
        return backgroundView
    } ()
    
    private lazy var headerView: HeaderView = {
        let headerView = HeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    } ()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    } ()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    } ()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.refreshControl = refreshControl
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = true
        return scrollView
    } ()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    } ()
    
    
    private lazy var hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.sectionInset = Constants.horizontalInsetsS

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemGray.withAlphaComponent(0.2)
        collectionView.layer.cornerRadius = 8
        return collectionView
    }()

    private lazy var dailyTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.backgroundColor = .systemGray.withAlphaComponent(0.2)
        tableView.layer.cornerRadius = 8
        tableView.separatorInset = Constants.horizontalInsetsS
        return tableView
    }()
    
    // MARK: - Init
    
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods of lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bind()
        setupUI()
        viewModel.checkLocationAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let gradient = backgroundView.layer.sublayers?.first as? CAGradientLayer else { return }
        gradient.frame = view.bounds
    }

    // MARK: - Methods

    private func bind() {
        viewModel.onUpdateUI = { [weak self] data in
            self?.updateUI(with: data)
        }
        viewModel.onShowFetchError = { [weak self] in
            self?.showFetchErrorAlert()
        }
        viewModel.onShowIndicator = { [weak self] shouldShow in
            self?.shouldShowIndicator(shouldShow)
        }
    }
    
    @objc private func refreshData() {
        refreshControl.endRefreshing()
        viewModel.checkLocationAuthorization()
    }
    
    private func showFetchErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка загрузки",
            message: nil,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "Повторить",
            style: .default
        ) { [weak self] _ in
            self?.viewModel.checkLocationAuthorization()
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    private func shouldShowIndicator(_ shouldShow: Bool) {
        view.isUserInteractionEnabled = !shouldShow
        UIView.animate(withDuration: 0.8) {
            self.contentView.alpha = shouldShow ? 0 : 1
            shouldShow ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
    
    private func updateGradient(for condition: String?) {
        guard let gradientLayer = backgroundView.layer.sublayers?.first as? CAGradientLayer else { return }
        
        let colors: [CGColor]
        switch condition?.lowercased() {
        case "sunny", "clear", "ясно", "солнечно":
            colors = [UIColor.systemYellow.cgColor, UIColor.systemBlue.cgColor]
        case "cloudy", "overcast", "облачно", "пасмурно":
            colors = [UIColor.systemGray.cgColor, UIColor.systemGray2.cgColor]
        case "rain", "shower", "дождь", "местами дождь", "небольшой ливневый дождь":
            colors = [UIColor.systemBlue.cgColor, UIColor.systemGray.cgColor]
        case "partly cloudy", "переменная облачность", "дымка":
            colors = [UIColor.systemBlue.cgColor, UIColor.systemGray.cgColor]
        default:
            colors = [UIColor.systemBlue.cgColor, UIColor.systemIndigo.cgColor]
        }
        gradientLayer.colors = colors
        
        let colorAnimation = CABasicAnimation(keyPath: "colors")
        colorAnimation.fromValue = colors
        colorAnimation.toValue = colors.reversed()
        colorAnimation.duration = 5.0
        colorAnimation.autoreverses = true
        colorAnimation.repeatCount = .infinity
        gradientLayer.add(colorAnimation, forKey: "colorAnimation")
    }
    
    private func setupUI() {
        setupScrollView()
        setupHeader()
        setupHourlyCollectionView()
        setupDailyTableView()
    }
    
    private func setupScrollView() {
        [backgroundView, scrollView, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
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
        contentView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func setupHourlyCollectionView() {
        hourlyCollectionView.dataSource = self
        hourlyCollectionView.delegate = self
        hourlyCollectionView.register(HourlyForecastCell.self, forCellWithReuseIdentifier: HourlyForecastCell.identifier)
        contentView.addSubview(hourlyCollectionView)
        NSLayoutConstraint.activate([
            hourlyCollectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Constants.paddingS * 2),
            hourlyCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingM),
            hourlyCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingM),
            hourlyCollectionView.heightAnchor.constraint(equalToConstant: Constants.hourlyCollectionViewHeight)
        ])
    }

    private func setupDailyTableView() {
        dailyTableView.dataSource = self
        dailyTableView.delegate = self
        dailyTableView.register(DailyForecastCell.self, forCellReuseIdentifier: DailyForecastCell.identifier)
        contentView.addSubview(dailyTableView)
        NSLayoutConstraint.activate([
            dailyTableView.topAnchor.constraint(equalTo: hourlyCollectionView.bottomAnchor, constant: Constants.paddingS),
            dailyTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingM),
            dailyTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingM),
            dailyTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dailyTableView.heightAnchor.constraint(
                equalToConstant: Constants.forecastDayCellHeight * CGFloat(Constants.forecastDaysCount))
        ])
    }

    private func updateUI(with weatherData: WeatherResponse ) {
        updateGradient(for: weatherData.current.condition.text)
        headerView.configure(with: weatherData)
        hourlyCollectionView.reloadData()
        dailyTableView.reloadData()
    }
}

// MARK: - Extensions

extension WeatherViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getHourlyForecast().count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "HourlyForecastCell",
            for: indexPath) as? HourlyForecastCell
        else { return UICollectionViewCell() }
        cell.configure(with: viewModel.getHourlyForecast()[safe: indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: Constants.forecastHourCellWidth,
            height: Constants.forecastHourCellHeight
        )
    }
}

extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.forecastDaysCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "DailyForecastCell",
            for: indexPath) as? DailyForecastCell
        else { return UITableViewCell() }
        cell.configure(with: viewModel.getDailyForecast()[safe: indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.forecastDayCellHeight
    }
}
