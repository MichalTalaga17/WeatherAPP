//
//  UserLocationView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 11/08/2024.
//

import Foundation
import SwiftUI
import CoreLocation

struct UserLocationView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            if let location = locationManager.location {
                Text("Latitude: \(location.latitude)")
                Text("Longitude: \(location.longitude)")
                Text("City: \(locationManager.cityName ?? "Unknown")")
                    .font(.title)
                    .padding(.top)
            } else {
                Text("Fetching location...")
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .navigationTitle("Your Location")
        .padding()
    }
}
