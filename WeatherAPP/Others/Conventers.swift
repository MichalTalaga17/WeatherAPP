//
//  Conventers.swift
//  WeatherAPP
//
//  Created by Michał Talaga
//

import Foundation


func convertMetersToKilometers(meters: Double) -> Int {
    return Int(meters / 1000.0)
}

func kelvinToCelsius(_ kelvin: Double) -> String {
    let celsius = kelvin - 273.15
    return String(format: "%0.0f°", celsius)
}

enum DateFormatType {
    case fullDateTime          // "dd.MM.yyyy HH:mm"
    case dayOfWeek             // "EEEE"
    case timeOnly              // "HH:mm"
    case dateOnly              // "dd.MM.yyyy"
    case dateWithMonthName     // "dd MMMM yyyy"
    case hourOnly              // "HH"
}

func formatDate(timestamp: Int, formatType: DateFormatType, timeZone: TimeZone) -> String {
    let date = Date(timeIntervalSince1970: Double(timestamp))
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = timeZone
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
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
    case .hourOnly:
        dateFormatter.dateFormat = "HH"
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

func windDirection(from degrees: Int) -> String {
    switch degrees {
    case 0..<23, 338...360:
        return "N"
    case 23..<68:
        return "NE"
    case 68..<113:
        return "E"
    case 113..<158:
        return "SE"
    case 158..<203:
        return "S"
    case 203..<248:
        return "SW"
    case 248..<293:
        return "W"
    case 293..<338:
        return "NW"
    default:
        return "N/A"
    }
}
