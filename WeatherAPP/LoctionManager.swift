//
//  LoctionManager.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation? {
        didSet {
            fetchCityName(from: location)
        }
    }
    @Published var cityName: String = "Unknown"

    private var requestLocationCompletion: ((Result<CLLocation, Error>) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    // CLLocationManagerDelegate methods

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        location = newLocation
        requestLocationCompletion?(.success(newLocation))
        requestLocationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        requestLocationCompletion?(.failure(error))
        requestLocationCompletion = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
        case .denied, .restricted:
            print("Location services are restricted or denied.")
        case .notDetermined:
            // Request authorization if it hasn't been determined yet
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("Unknown location authorization status.")
        }
    }
    
    // Custom Methods

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
    
    func requestLocation(completion: @escaping (Result<CLLocation, Error>) -> Void) {
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                // Authorization status is not determined, will wait for the callback
                self.requestLocationCompletion = completion
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.requestLocation()
                self.requestLocationCompletion = completion
            case .denied, .restricted:
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Location services are restricted or denied."])))
            @unknown default:
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown location authorization status."])))
            }
        } else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Location services are not enabled."])))
        }
    }
}
