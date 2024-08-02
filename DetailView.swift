//
//  DetailView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 02/08/2024.
//

import SwiftUI

struct DetailView: View {
    let text: String

    var body: some View {
        VStack {
            Text("You entered: \(text)")
                .padding()
            // Tu można dodać więcej elementów widoku
        }
        .navigationTitle(text)
    }
}

#Preview{
    DetailView(text: "New York")
}
