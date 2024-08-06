//
//  GradientTestView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 06/08/2024.
//

import SwiftUI

struct GradientTestView: View {
    let weatherIcons = [
            "01d", "01n", "02d", "02n", "03d", "03n",
            "04d", "04n", "09d", "09n", "10d", "10n",
            "11d", "11n", "13d", "13n", "50d", "50n"
        ]
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(weatherIcons, id: \.self) { iconName in
                    gradientBackground2(for: iconName)
                        
                        .frame(height: 800)
                        .overlay(
                            Text(iconName)
                                .font(.title)
                                .foregroundColor(.white)
                                .bold()
                        )
                        .padding(.bottom, 10)
                        .onAppear(){
                            print(
                                iconName)
                        }
                }
            }
            .padding()
            
        }
    }
}

#Preview {
    GradientTestView()
}
