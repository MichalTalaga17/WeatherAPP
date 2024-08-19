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
                
                ScrollView(){
                    
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
