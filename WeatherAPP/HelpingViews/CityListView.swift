//
//  CityListView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import SwiftUI

struct CityListView: View {
    private let cities: [String] = ["New York", "London", "Tokyo", "Paris", "Sydney"]

    var body: some View {
        NavigationView {
            List(cities, id: \.self) { city in
                NavigationLink(destination: Text(city)
                                .font(.largeTitle)
                                .padding()
                                .navigationTitle(city)) {
                    Text(city)
                }
            }
        }
    }
}

#Preview {
    CityListView()
}
