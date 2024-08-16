//
//  WeatherAPPApp.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 02/08/2024.
//

import SwiftUI
import SwiftData

@main
struct WeatherAPPApp: App {
    var body: some Scene {
        WindowGroup {
            TabView{
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                WeatherView()
                    .tabItem {
                        Image(systemName: "cloud.fill")
                        Text("Weather")
                    }
                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                
            }
        }
    }
}
