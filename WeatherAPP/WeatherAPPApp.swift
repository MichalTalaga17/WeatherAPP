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
            TabView {
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                            .foregroundStyle(Color.black.opacity(0.8))
                        Text("Settings")
                            .foregroundStyle(Color.black.opacity(0.8))
                    }
                    
                
                WeatherView()
                    .tabItem {
                        Image(systemName: "cloud.fill")
                            .foregroundStyle(Color.black.opacity(0.8))
                        Text("Weather")
                            .foregroundStyle(Color.black.opacity(0.8))
                    }
                    
                
                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.black.opacity(0.8))
                        Text("Search")
                        .foregroundStyle(Color.black.opacity(0.8))
                    }
            }
            .accentColor(.black)
            
            .modelContainer(for: FavouriteCity.self)
        }
    }
}
