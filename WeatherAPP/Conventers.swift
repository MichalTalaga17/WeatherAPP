//
//  Conventers.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 04/08/2024.
//

import Foundation

func kelvinToCelsius(_ kelvin: Double) -> String {
    let celsius = kelvin - 273.15
    return String(format: "%0.0f °C", celsius)
}
enum DateFormatType {
    case fullDateTime          // "dd.MM.yyyy HH:mm"
    case dayOfWeek             // "EEEE"
    case timeOnly              // "HH:mm"
    case dateOnly              // "dd.MM.yyyy"
    case dateWithMonthName     // "dd MMMM yyyy"
}

func formatDate(timestamp: Int, formatType: DateFormatType) -> String {
    let date = Date(timeIntervalSince1970: Double(timestamp))
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set timezone to GMT
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Set locale to avoid unexpected localization
    
    switch formatType {
    case .fullDateTime:
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
    case .dayOfWeek:
        dateFormatter.dateFormat = "EEEE"
    case .timeOnly:
        dateFormatter.dateFormat = "HH:mm"
    case .dateOnly:
        dateFormatter.dateFormat = "dd.MM.yyyy"
    case .dateWithMonthName:
        dateFormatter.dateFormat = "dd MMMM yyyy"
    }
    
    return dateFormatter.string(from: date)
}

func dateToTimestamp(dateString: String) -> TimeInterval? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    if let date = dateFormatter.date(from: dateString) {
        return date.timeIntervalSince1970
    } else {
        return nil
    }
}


