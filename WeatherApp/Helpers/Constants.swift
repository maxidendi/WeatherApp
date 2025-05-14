//
//  Constants.swift
//  WeatherApp
//
//  Created by Денис Максимов on 13.05.2025.
//

import UIKit

enum Constants {
    static let apiKey = "9fae8be7cde3432586c102048251305"
    static let baseURLString = "http://api.weatherapi.com/v1"
    static let dateFormatter = DateFormatter()
    
    static let forecastDaysCount: Int = 7
    static let forecastDayCellHeight: CGFloat = 50
    static let forecastHourCellHeight: CGFloat = 100
    static let forecastHourCellWidth: CGFloat = 60
    static let hourlyCollectionViewHeight: CGFloat = 120
    static let paddingS: CGFloat = 16
    static let paddingM: CGFloat = 24
    static let paddingL: CGFloat = 32
    static let horizontalInsetsS: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
}
