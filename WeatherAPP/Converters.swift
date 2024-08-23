//
//  Converters.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import Foundation

func aqiDescription(for aqi: Int) -> String {
    switch aqi {
    case 1:
        return "Good"
    case 2:
        return "Fair"
    case 3:
        return "Moderate"
    case 4:
        return "Poor"
    case 5:
        return "Very Poor"
    default:
        return "Unknown"
    }
}

func formatUnixTimeToHourAndMinute(_ unixTime: Int, timezone: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
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
