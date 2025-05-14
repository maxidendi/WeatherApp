//
//  HourlyForecastCell.swift
//  WeatherApp
//
//  Created by Денис Максимов on 12.05.2025.
//

import UIKit
import Kingfisher

final class HourlyForecastCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "HourlyForecastCell"
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    } ()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        return label
    } ()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    } ()
    
    private lazy var tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    } ()
    
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.kf.cancelDownloadTask()
        timeLabel.text = nil
        tempLabel.text = nil
        iconImageView.image = nil
    }

    func configure(with hour: HourForecast?) {
        guard let hour else { return }
        timeLabel.text = String(hour.time.split(separator: " ").last ?? "")
        tempLabel.text = "\(hour.temp_c)℃"
        loadIcon(from: hour.condition.icon)
    }
    
    private func setupUI() {
        [timeLabel, iconImageView, tempLabel].forEach {
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
        iconImageView.kf.indicatorType = .activity
        iconImageView.kf.setImage(with: url)
    }
}
