//
//  GeocodingViewModel.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 02/08/2024.
//

import Foundation
import CoreLocation

class GeocodingViewModel: NSObject, ObservableObject {
    private let geocoder = CLGeocoder()
    
    @Published var location: CLLocation?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func geocode(cityName: String) async {
        isLoading = true
        errorMessage = nil
        location = nil
        
        do {
            let placemarks = try await geocoder.geocodeAddressString(cityName)
            if let location = placemarks.first?.location {
                self.location = location
            } else {
                self.errorMessage = "No location found for city: \(cityName)"
            }
        } catch {
            self.errorMessage = "Geocoding error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
