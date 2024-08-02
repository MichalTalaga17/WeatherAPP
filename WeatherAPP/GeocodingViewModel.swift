//
//  GeocodingViewModel.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 02/08/2024.
//

import Foundation
import SwiftUI
import CoreLocation

class GeocodingViewModel: NSObject, ObservableObject {
    private let geocoder = CLGeocoder()
    @Published var location: CLLocation?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    func geocode(cityName: String) {
        guard !cityName.isEmpty else {
            self.errorMessage = "City name cannot be empty."
            return
        }

        self.isLoading = true
        self.errorMessage = nil

        geocoder.geocodeAddressString(cityName) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Geocoding error"
                    self?.location = nil
                    return
                }

                guard let location = placemarks?.first?.location else {
                    self?.errorMessage = "No location found for city: \(cityName)"
                    self?.location = nil
                    return
                }

                self?.location = location
            }
        }
    }
}
