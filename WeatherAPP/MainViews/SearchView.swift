//
//  ContentView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 02/08/2024.
//

import SwiftUI

struct SearchView: View {
    private let cities: [String] = ["New York", "London", "Tokyo", "Paris", "Sydney"]
    @State private var cityName: String = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Input Field
                TextField("Search for city", text: $cityName)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(8)
                    .padding()

                // List of Cities
                List(cities, id: \.self) { city in
                    NavigationLink(destination: Text(city)
                                    .font(.largeTitle)
                                    .padding()
                                    .navigationTitle(city)) {
                        Text(city)
                    }
                }
            }
            .navigationTitle("Search")
        }
    }
}

#Preview {
    SearchView()
}
