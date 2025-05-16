//
//  Models.swift
//  WeatherApp
//
//  Created by Денис Максимов on 12.05.2025.
//

import Foundation

struct WeatherResponse: Codable {
    let location: Location
    let current: Current
    let forecast: Forecast
}

struct Location: Codable {
    let name: String
}

struct Current: Codable {
    let temp_c: Double
    let condition: Condition
}

struct Forecast: Codable {
    let forecastday: [DayForecast]
}

struct DayForecast: Codable {
    let date: String
    let day: Day
    let hour: [HourForecast]
}

struct Day: Codable {
    let maxtempC: Double
    let mintempC: Double
    let condition: Condition
    
    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case mintempC = "mintemp_c"
        case condition
    }
}

struct HourForecast: Codable {
    let time: String
    let temp_c: Double
    let condition: Condition
}

struct Condition: Codable {
    let text: String
    let icon: String
}
