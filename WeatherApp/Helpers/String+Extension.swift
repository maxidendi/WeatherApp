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
    
    static func isSameHour(as input: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        
        guard let inputDate = formatter.date(from: input) else { return false }
        
        let calendar = Calendar.current
        let inputHour = calendar.component(.hour, from: inputDate)
        let currentHour = calendar.component(.hour, from: Date())
        
        return inputHour == currentHour
    }
    
    static func isDateInRange(_ input: String) -> Bool {
        let formatter = Constants.dateFormatter
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current

        guard let date = formatter.date(from: input) else { return false }

        let calendar = Calendar.current
        let now = calendar.date(bySetting: .minute, value: 0, of: Date()) ?? Date()

        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
              let endOfTomorrow = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: tomorrow) else {
            return false
        }

        return date >= now && date <= endOfTomorrow
    }
}
