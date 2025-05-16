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
    let condition: Condition
    let avgtempC: Double
    let maxwindKph: Double
    let avghumidity: Double
    
    enum CodingKeys: String, CodingKey {
        case condition
        case avgtempC = "avgtemp_c"
        case maxwindKph = "maxwind_kph"
        case avghumidity
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
