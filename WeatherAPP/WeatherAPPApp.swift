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
    enum Units: String, Identifiable, CaseIterable {
        case metric = "metric"
        case imperial = "imperial"
        
        var id: String { self.rawValue }
    }

    enum FontSize: String, Identifiable, CaseIterable {
        case small = "small"
        case medium = "medium"
        case large = "large"
        
        var id: String { self.rawValue }
    }
    
    

    var body: some Scene {
        WindowGroup {
            ContentView()
            
            .modelContainer(sharedModelContainer)
        }
        
    }
}
