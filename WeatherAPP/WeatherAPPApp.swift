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
        City.self,
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
            ContentView()
            
            .modelContainer(sharedModelContainer)
        }
        
    }
}
