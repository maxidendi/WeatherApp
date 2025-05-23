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
        label.textColor = .label
        return label
    } ()
    
    private lazy var rangeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
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
        rangeLabel.text = nil
        iconImageView.image = nil
    }

    func configure(with forecast: DayForecast?) {
        guard let forecast else { return }
        dayLabel.text = String.formatDateString(forecast.date)
        rangeLabel.text = "\(forecast.day.mintempC)° / \(forecast.day.maxtempC)°"
        loadIcon(from: forecast.day.condition.icon)
    }
    
    private func setupUI() {
        backgroundColor = .clear
        [dayLabel, iconImageView, rangeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            rangeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            rangeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
        ])
    }

    private func loadIcon(from path: String) {
        guard let url = URL(string: "https:\(path)") else { return }
        iconImageView.kf.indicatorType = .activity
        iconImageView.kf.setImage(with: url)
    }
}
