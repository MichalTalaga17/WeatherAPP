//
//  HeaderView.swift
//  WeatherAPP
//
//  Created by Michał Talaga
//

import SwiftUI

struct HeaderView: View {
    @Binding var cityName: String
    @Binding var cityName2: String
    
    var body: some View {
        VStack {
            Text("Pogoda")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 10) {
                TextField("Podaj miasto", text: $cityName)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(8)
                
                NavigationLink(destination: LocationWeatherView(cityName: cityName2, favourite: false)) {
                    Text("Szukaj")
                        .font(.callout)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    cityName2 = cityName
                    cityName = ""
                })
            }
        }
        .padding(.bottom, 40)
    }
}
