//
//  ContentView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 02/08/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var inputText = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your city", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                NavigationLink(destination: DetailView(text: inputText)) {
                    Text("Go to Detail View")
                }
                .padding()
            }
            .padding()
            .navigationTitle("Weather")
        }
    }
}

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


#Preview {
    ContentView()
}
