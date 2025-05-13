//
//  String+Extenson.swift
//  WeatherApp
//
//  Created by Денис Максимов on 13.05.2025.
//

import Foundation

extension String {
    static func formatDateString(_ input: String) -> String? {
        let inputFormatter = Constants.dateFormatter
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "ru_RU")

        guard let date = inputFormatter.date(from: input) else { return nil }

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ru_RU")
        outputFormatter.dateFormat = "EE, d MMMM"

        let formatted = outputFormatter.string(from: date)
        return formatted.capitalized
    }
}
