//
//  AboutView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        Form {
            Section(header: Text("About This App")) {
                VStack(alignment: .leading, spacing: 16) {
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text("WeatherApp is a comprehensive weather application that provides real-time weather updates, forecasts, and notifications. Our goal is to keep you informed about the weather conditions wherever you are, so you can plan your activities with confidence.")
                        .font(.body)
                        .lineSpacing(4)
                    
                    Text("Version 2.0")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Section(header: Text("Links")) {
                NavigationLink("Privacy Policy", destination: PrivacyPolicyView())
                Link("Contact Support", destination: URL(string: "mailto:michal.talaga.programming@gmail.com")!)
                Link("GitHub project", destination: URL(string: "https://github.com/MichalTalaga17/WeatherAPP")!)
            }
            
            
        }
        .navigationTitle("About")
    }
}

#Preview {
    AboutView()
}
