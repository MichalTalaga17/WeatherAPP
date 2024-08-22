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
    @State private var selectedTab = 1
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FavouriteCity.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(0)
                
                MainView()
                    .tabItem {
                        Image(systemName: "cloud.fill")
                        Text("Weather")
                    }
                    .tag(1)
                
                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .tag(2)
            }
            .accentColor(.white)
            
            .modelContainer(for: FavouriteCity.self)
        }
    }
}
