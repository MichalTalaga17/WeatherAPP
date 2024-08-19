//
//  City.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 19/08/2024.
//

import Foundation
import SwiftData

@Model
final class FavouriteCity {
    @Attribute(.unique) var name: String
    var temperature: Double? = nil
    var weatherIcon: String? = nil

    init(name: String) {
        self.name = name
    }
}
