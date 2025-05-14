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
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
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
        layout.sectionInset = Constants.horizontalInsetsS

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemGray.withAlphaComponent(0.3)
        collectionView.layer.cornerRadius = 8
        return collectionView
    }()

    private let dailyTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.backgroundColor = .systemGray.withAlphaComponent(0.3)
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
        contentView.isHidden = shouldShow
        contentView.alpha = shouldShow ? 1 : 0
        UIView.animate(withDuration: 0.8) {
            self.contentView.alpha = shouldShow ? 0 : 1
            shouldShow ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
    
    private func setupUI() {
        setupScrollView()
        setupHeader()
        setupHourlyCollectionView()
        setupDailyTableView()
    }
    
    private func setupScrollView() {
        [scrollView, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
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
        [locationLabel, tempLabel, conditionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            locationLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: Constants.paddingL * 2),
            
            tempLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tempLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: Constants.paddingS),
            
            conditionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            conditionLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: Constants.paddingS),
        ])
    }
    
    private func setupHourlyCollectionView() {
        hourlyCollectionView.dataSource = self
        hourlyCollectionView.delegate = self
        hourlyCollectionView.register(HourlyForecastCell.self, forCellWithReuseIdentifier: HourlyForecastCell.identifier)
        contentView.addSubview(hourlyCollectionView)
        NSLayoutConstraint.activate([
            hourlyCollectionView.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: Constants.paddingS * 2),
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
        locationLabel.text = weatherData.location.name
        tempLabel.text = "\(weatherData.current.temp_c)℃"
        conditionLabel.text = weatherData.current.condition.text
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
