import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedCity") private var selectedCity: String = "San Francisco"
    @AppStorage("units") private var units: Units = .metric
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
    @AppStorage("fontSize") private var fontSize: FontSize = .medium

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Location")) {
                    Picker("City", selection: $selectedCity) {
                        Text("San Francisco").tag("San Francisco")
                        Text("New York").tag("New York")
                        Text("London").tag("London")
                        Text("Warsaw").tag("Warsaw")
                        Text("Tokyo").tag("Tokyo")
                    }
                }
                
                Section(header: Text("Units")) {
                    Picker("units", selection: $units) {
                        Text("Metric").tag(Units.metric)
                        Text("Imperial").tag(Units.imperial)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                }
                
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                    Picker("Font Size", selection: $fontSize) {
                        ForEach(FontSize.allCases, id: \.self) { size in
                            Text(size.rawValue.capitalized).tag(size)
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    NavigationLink("About the App") {
                        //AboutView()
                    }
                    NavigationLink("Privacy Policy") {
                        //PrivacyPolicyView()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}


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

#Preview {
    SettingsView()
}
