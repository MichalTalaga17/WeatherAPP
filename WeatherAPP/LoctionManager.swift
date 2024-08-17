//
//  LoctionManager.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import SwiftUI
import CoreLocation

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation? {
        didSet {
            fetchCityName(from: location)
        }
    }
    @Published var cityName: String = "Unknown"
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        location = newLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        cityName = "Unknown"
    }
    
    private func fetchCityName(from location: CLLocation?) {
        guard let location = location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                self?.cityName = "Unknown"
                return
            }
            
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? "Unknown"
                self?.cityName = city
            } else {
                print("No placemark found, setting city as Unknown")
                self?.cityName = "Unknown"
            }
        }
    }
}
