//
//  City.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 06/08/2024.
//

import Foundation
import SwiftData

@Model
final class City {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

