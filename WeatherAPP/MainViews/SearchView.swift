//
//  ContentView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 02/08/2024.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Query private var cities: [FavouriteCity]
    @State private var cityName: String = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                HStack {
                    TextField("Search for city", text: $cityName)
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(8)
                    
                    NavigationLink(destination: WeatherView(cityName: cityName)) {
                        Text("Go")
                            .padding()
                            .background(cityName.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(cityName.isEmpty)
                }.padding()
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(cities, id: \.self) { city in
                        NavigationLink(destination: WeatherView(cityName: city.name)) {
                            HStack{
                                Text(city.name)
                                Spacer()
                            }
                            .font(.headline)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                            
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer()
            }
            .navigationTitle("Search")
        }
    }
}

#Preview {
    SearchView()
}
