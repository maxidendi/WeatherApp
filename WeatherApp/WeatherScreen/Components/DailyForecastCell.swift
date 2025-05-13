//
//  DailyForecastCell.swift
//  WeatherApp
//
//  Created by Денис Максимов on 12.05.2025.
//

import UIKit

final class DailyForecastCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "DailyForecastCell"
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        return stackView
    } ()

    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    } ()
    
    private lazy var rangeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
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

    func configure(with forecast: ForecastDay) {
        dayLabel.text = String(forecast.date.suffix(5))
        rangeLabel.text = "\(forecast.day.mintemp_c)° / \(forecast.day.maxtemp_c)°"
        loadIcon(from: forecast.day.condition.icon)
    }
    
    private func setupUI() {
        [dayLabel, iconImageView, rangeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func loadIcon(from path: String) {
        guard let url = URL(string: "https:\(path)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    self.iconImageView.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}
