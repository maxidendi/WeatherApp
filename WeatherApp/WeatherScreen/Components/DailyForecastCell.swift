//
//  DailyForecastCell.swift
//  WeatherApp
//
//  Created by Денис Максимов on 12.05.2025.
//

import UIKit
import Kingfisher

final class DailyForecastCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "DailyForecastCell"

    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.textColor = .label
        return label
    } ()
    
    private lazy var tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    } ()
    
    private lazy var humidityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    } ()
    
    private lazy var windLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    } ()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.kf.cancelDownloadTask()
        dayLabel.text = nil
        tempLabel.text = nil
        iconImageView.image = nil
    }

    func configure(with forecast: DayForecast?) {
        guard let forecast else { return }
        dayLabel.text = "\(forecast.day.condition.text)\n\(String.formatDateString(forecast.date) ?? "")"
        humidityLabel.text = "Влажность: \(forecast.day.avghumidity)%"
        windLabel.text = "Ветер: \(forecast.day.maxwindKph) км/ч"
        tempLabel.text = "\(forecast.day.avgtempC)°C"
        loadIcon(from: forecast.day.condition.icon)
    }
    
    private func setupUI() {
        backgroundColor = .clear
        [dayLabel, iconImageView, tempLabel, windLabel, humidityLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.paddingS),
            dayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.paddingS),
            dayLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 150),
            dayLabel.heightAnchor.constraint(equalToConstant: 40),
            
            tempLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.paddingS),
            tempLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.paddingS),
            
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            windLabel.centerYAnchor.constraint(equalTo: dayLabel.centerYAnchor),
            windLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.paddingS),
            
            humidityLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.paddingS),
            humidityLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.paddingS)
        ])
    }

    private func loadIcon(from path: String) {
        guard let url = URL(string: "https:\(path)") else { return }
        iconImageView.kf.indicatorType = .activity
        iconImageView.kf.setImage(with: url)
    }
}
