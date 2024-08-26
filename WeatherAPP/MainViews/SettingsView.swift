//
//  SettingsView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    // AppStorage Properties
    @AppStorage("units") private var units: Units = .metric
    @AppStorage("iconsColorsBasedOnWeather") private var iconsColorsBasedOnWeather: Bool = false
    @AppStorage("backgroundStyle") private var backgroundStyle: BackgroundStyle = .none
    @AppStorage("stormNotifications") private var stormNotifications: Bool = true
    @AppStorage("airQuality") private var airQuality: Bool = true
    @AppStorage("dataSavingMode") private var dataSavingMode: Bool = false
    @AppStorage("language") private var language: Language = .english
    @AppStorage("weatherUpdateFrequency") private var weatherUpdateFrequency: UpdateFrequency = .hourly
    @AppStorage("defaultCity") private var defaultCity: String = "Your location"
    @AppStorage("mainIcon") private var mainIcon: String = ""
    
    // Query Property for Favorite Cities
    @Query private var cities: [FavouriteCity]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                if backgroundStyle == .gradient {
                    gradientBackground()
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Color.clear
                        .edgesIgnoringSafeArea(.all)
                }
                
                Form {
                    defaultCitySection
                    unitsSection
                    appearanceSection
                    notificationsSection
                    preferencesSection
                    generalSection
                    aboutSection
                }
                .background(Color.white)
                .navigationTitle("Settings")
            }
        }
    }
    
    // MARK: - Sections
    
    private var defaultCitySection: some View {
        Section(header: Text("Default City")) {
            Picker("Select City", selection: $defaultCity) {
                ForEach(cities) { city in
                    Text(city.name).tag(city.name)
                }
                Text("Your location").tag("Your location")
            }
        }
    }
    
    private var unitsSection: some View {
        Section(header: Text("Units")) {
            Picker("Temperature Units", selection: $units) {
                Text("Metric").tag(Units.metric)
                Text("Imperial").tag(Units.imperial)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var appearanceSection: some View {
        Section(header: Text("Appearance")) {
            Toggle("Icons Colors Based on Weather", isOn: $iconsColorsBasedOnWeather)
            Picker("Background Style", selection: $backgroundStyle) {
                Text("None").tag(BackgroundStyle.none)
                Text("Gradient").tag(BackgroundStyle.gradient)
            }
        }
    }
    
    private var notificationsSection: some View {
        Section(header: Text("Notifications")) {
            Toggle("Storm Notifications", isOn: $stormNotifications)
                .disabled(true)
        }
    }
    
    private var preferencesSection: some View {
        Section(header: Text("Preferences")) {
            Picker("Widgets update Frequency", selection: $weatherUpdateFrequency) {
                Text("15 Minutes").tag(UpdateFrequency.minutes15)
                Text("30 Minutes").tag(UpdateFrequency.minutes30)
                Text("Hourly").tag(UpdateFrequency.hourly)
                Text("Daily").tag(UpdateFrequency.daily)
            }
            .disabled(true)
        }
    }
    
    private var generalSection: some View {
        Section(header: Text("General")) {
            Picker("Language", selection: $language) {
                ForEach(Language.allCases, id: \.self) { lang in
                    Text(lang.rawValue).tag(lang)
                }
            }
            .disabled(true)
            
            Toggle("Data Saving Mode", isOn: $dataSavingMode)
                .disabled(true)
            
            Toggle("Air Quality Information", isOn: $airQuality)
                .disabled(true)
        }
    }
    
    private var aboutSection: some View {
        Section(header: Text("About")) {
            NavigationLink("About the App") {
                AboutView()
            }
            NavigationLink("Privacy Policy") {
                PrivacyPolicyView()
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func gradientBackground() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Enums

enum Units: String, Identifiable, CaseIterable {
    case metric = "metric"
    case imperial = "imperial"
    
    var id: String { self.rawValue }
}

enum WindSpeedUnits: String, Identifiable, CaseIterable {
    case kilometersPerHour = "Kilometers per Hour"
    case milesPerHour = "Miles per Hour"
    case metersPerSecond = "Meters per Second"
    
    var id: String { self.rawValue }
}

enum UpdateFrequency: String, Identifiable, CaseIterable {
    case minutes15 = "15 Minutes"
    case minutes30 = "30 Minutes"
    case hourly = "Hourly"
    case daily = "Daily"
    
    var id: String { self.rawValue }
}

enum Language: String, CaseIterable, Identifiable {
    case english = "English"
    case polish = "Polish"
    case german = "German"
    
    var id: String { self.rawValue }
}

enum BackgroundStyle: String, CaseIterable, Identifiable {
    case none = "None"
    case animated = "Animated"
    case gradient = "Gradient"
    
    var id: String { self.rawValue }
}

// MARK: - Preview

#Preview {
    SettingsView()
}

