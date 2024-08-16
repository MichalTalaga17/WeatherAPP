import SwiftUI

struct SettingsView: View {
    @AppStorage("units") private var units: Units = .metric

    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Units")) {
                    Picker("units", selection: $units) {
                        Text("Metric").tag(Units.metric)
                        Text("Imperial").tag(Units.imperial)
                    }
                    .pickerStyle(SegmentedPickerStyle())
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



#Preview {
    SettingsView()
}
