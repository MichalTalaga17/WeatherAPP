//
//  ContentView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 02/08/2024.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct ContentView: View {
    @StateObject private var geocodingViewModel = GeocodingViewModel()
    @State private var cityName: String = ""
    @State private var lat: Double = 0.0
    @State private var lon: Double = 0.0
    
    var body: some View {
        VStack {
            TextField("Enter city name", text: $cityName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Get Weather") {
                geocodingViewModel.geocode(cityName: cityName)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if geocodingViewModel.isLoading {
                ProgressView()
            } else {
                if let location = geocodingViewModel.location {
                    Text("Latitude: \(location.coordinate.latitude)")
                    Text("Longitude: \(location.coordinate.longitude)")
                } else if let errorMessage = geocodingViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
