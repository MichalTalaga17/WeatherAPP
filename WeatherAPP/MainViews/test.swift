//
//  test.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 22/08/2024.
//

import SwiftUI

struct GradientTestView: View {
    // MARK: - Properties
    private let icons = [
        "01d", "01n", "02d", "02n", "03d", "03n",
        "04d", "04n", "09d", "09n", "10d", "10n",
        "11d", "11n", "13d", "13n", "50d", "50n"
    ]
    
    @State private var selectedIcon: String = "01d"
    
    var body: some View {
        VStack {
            VStack {
                // Picker to select the gradient
                Picker("Select Icon", selection: $selectedIcon) {
                    ForEach(icons, id: \.self) { icon in
                        Text(icon)
                            .tag(icon)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                // Display the selected icon
                Text("Selected Icon: \(selectedIcon)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
            }
            // Gradient background based on selected icon
            gradientBackground(for: selectedIcon)
                .edgesIgnoringSafeArea(.all)
            
            
        }
    }
}

#Preview {
    GradientTestView()
}
