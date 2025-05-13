//
//  Array+Extension.swift
//  WeatherApp
//
//  Created by Денис Максимов on 13.05.2025.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
