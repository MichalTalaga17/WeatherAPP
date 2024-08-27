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
    @AppStorage("defaultCity") private var defaultCity: String = "Your location"
    @AppStorage("mainIcon") private var mainIcon: String = ""
    
    // UserDefaults for weatherUpdateFrequency
    @State private var weatherUpdateFrequency: UpdateFrequency = {
        let storedValue = UserDefaults.standard.string(forKey: "weatherUpdateFrequency") ?? UpdateFrequency.hourly.rawValue
        return UpdateFrequency(rawValue: storedValue) ?? .hourly
    }()
    
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
            Toggle("Data Saving Mode", isOn: $dataSavingMode)
                .onChange(of: dataSavingMode) { newValue in
                    if newValue {
                        // Ustaw częstotliwość odświeżania na godzinę, jeśli jest włączony tryb oszczędzania danych
                        if weatherUpdateFrequency != .hourly {
                            weatherUpdateFrequency = .hourly
                        }
                        UserDefaults.standard.set(weatherUpdateFrequency.rawValue, forKey: "weatherUpdateFrequency")
                    }
                }
            
           
                Picker("Widgets update Frequency", selection: $weatherUpdateFrequency) {
                    Text("5 Minutes").tag(UpdateFrequency.minutes5)
                    Text("10 Minutes").tag(UpdateFrequency.minutes10)
                    Text("30 Minutes").tag(UpdateFrequency.minutes30)
                    Text("Hourly").tag(UpdateFrequency.hourly)
                }
                .disabled(dataSavingMode)
                .onChange(of: weatherUpdateFrequency) { newValue in
                    if dataSavingMode && newValue != .hourly {
                        // Jeśli tryb oszczędzania danych jest włączony, wymuszamy godzinne odświeżanie
                        weatherUpdateFrequency = .hourly
                    }
                    UserDefaults.standard.set(weatherUpdateFrequency.rawValue, forKey: "weatherUpdateFrequency")
                }
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
            
            
            
            Toggle("Air Quality Information", isOn: $airQuality)
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
    case minutes5 = "5 Minutes"
    case minutes10 = "10 Minutes"
    case minutes30 = "30 Minutes"
    case hourly = "Hourly"
    
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
