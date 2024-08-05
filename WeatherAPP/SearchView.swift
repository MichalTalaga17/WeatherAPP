//
//  SearchView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 05/08/2024.
//

import SwiftUI

struct SearchView: View {
    @State private var cityName = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                VStack {
                    Text("Pogoda")
                        .font(.largeTitle .bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 10) {
                        TextField("Podaj miasto", text: $cityName)
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                        
                        
                        Button("Szukaj") {
                            NavigationLink(destination: LocationWeatherView()) {
                                // Empty closure, but you could add an icon here
                                
                            }
                            
                        }
                        .font(.callout)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    SearchView()
}
