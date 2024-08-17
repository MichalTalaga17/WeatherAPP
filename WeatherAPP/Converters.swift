//
//  Converters.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import Foundation

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

func formatUnixTimeToHourAndMinute(_ unixTime: Int, timezone: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(unixTime + timezone))
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: date)
}

func extractHour(from dateString: String) -> String {
    // Definiujemy format daty zgodny z danymi wejściowymi
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    // Konwertujemy string na obiekt Date
    if let date = dateFormatter.date(from: dateString) {
        // Ustawiamy format, aby wyciągnąć tylko godzinę
        dateFormatter.dateFormat = "H"
        let hourString = dateFormatter.string(from: date)
        return hourString
    } else {
        return "Invalid date"
    }
}

func formatUnixTime(_ unixTime: TimeInterval, withMinutes: Bool = true) -> String {
    let date = Date(timeIntervalSince1970: unixTime)
    let dateFormatter = DateFormatter()
    
    if withMinutes {
        dateFormatter.dateFormat = "HH:mm" // Format z godzinami i minutami
    } else {
        dateFormatter.dateFormat = "HH" // Format tylko z godzinami
    }
    
    return dateFormatter.string(from: date)
}
