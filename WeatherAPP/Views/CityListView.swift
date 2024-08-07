//
//  CityListView.swift
//  WeatherAPP
//
//  Created by Michał Talaga
//

import SwiftUI
import SwiftData

struct CityListView: View {
    @Environment(\.modelContext) private var modelContext
    var cities: [City]
    
    var body: some View {
        ForEach(cities) { city in
            CityRowView(city: city)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(8)
                .foregroundStyle(Color.white)
                .task {
                    await fetchWeatherData(for: city)
                }
        }
        .onDelete(perform: deleteItems)
        .background(Color.white.opacity(0))
    }
    
    func fetchWeatherData(for city: City) async {
        do {
            try await fetchCurrentWeatherData() { result in
                switch result {
                case .success(let data):
                    print("Fetched data for \(city.name): \(data)")
                case .failure(let error):
                    // Handle the error appropriately
                    print("Failed to fetch weather data for \(city.name): \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error in fetchWeatherData: \(error.localizedDescription)")
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(cities[index])
            }
        }
    }
}

