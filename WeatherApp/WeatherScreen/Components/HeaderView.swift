//
//  HeaderView.swift
//  WeatherApp
//
//  Created by Денис Максимов on 14.05.2025.
//

import UIKit

final class HeaderView: UIView {
    
    // MARK: - Properties
    
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
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func configure(with weatherData: WeatherResponse) {
        animateTextChange(label: locationLabel, newText: weatherData.location.name)
        animateTextChange(label: tempLabel, newText: "\(weatherData.current.temp_c)℃")
        animateTextChange(label: conditionLabel, newText: weatherData.current.condition.text)
    }
    
    private func animateTextChange(label: UILabel, newText: String) {
        UIView.transition(with: label, duration: 0.3, options: .transitionCrossDissolve) {
            label.text = newText
        }
    }
    
    private func setupUI() {
        [locationLabel, tempLabel, conditionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            locationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.paddingL * 2),
            
            tempLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            tempLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: Constants.paddingS),
            
            conditionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            conditionLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: Constants.paddingS),
            conditionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
