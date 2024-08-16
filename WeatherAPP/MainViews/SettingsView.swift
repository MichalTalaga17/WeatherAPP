//
//  SettingsView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("units") private var units: Units = .metric
    @AppStorage("accentColorBasedOnWeather") private var accentColorBasedOnWeather: Bool = false
    @AppStorage("minimalistMode") private var minimalistMode: Bool = false
    @AppStorage("animatedBackgrounds") private var animatedBackgrounds: Bool = false
    @AppStorage("gradientBackground") private var gradientBackground: Bool = false
    @AppStorage("stormNotifications") private var stormNotifications: Bool = true
    @AppStorage("airQuality") private var airQuality: Bool = true
    @AppStorage("dataSavingMode") private var dataSavingMode: Bool = false
    @AppStorage("language") private var language: Language = .english
    @AppStorage("dayNightMode") private var dayNightMode: DayNightMode = .auto
    @AppStorage("windSpeedUnits") private var windSpeedUnits: WindSpeedUnits = .kilometersPerHour
    @AppStorage("weatherUpdateFrequency") private var weatherUpdateFrequency: UpdateFrequency = .hourly
    @AppStorage("defaultCity") private var defaultCity: String = "New York" // Change this to String

    private let cities: [City] = [.newYork, .london, .tokyo, .paris, .sydney]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Default City")) {
                    Picker("Select City", selection: $defaultCity) {
                        ForEach(cities) { city in
                            Text(city.name).tag(city.name) // Use city.name here
                        }
                    }
                }

                Section(header: Text("Units")) {
                    Picker("Temperature Units", selection: $units) {
                        Text("Celsius").tag(Units.metric)
                        Text("Fahrenheit").tag(Units.imperial)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Picker("Wind Speed", selection: $windSpeedUnits) {
                        Text("km/h").tag(WindSpeedUnits.kilometersPerHour)
                        Text("mph").tag(WindSpeedUnits.milesPerHour)
                        Text("m/s").tag(WindSpeedUnits.metersPerSecond)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Appearance")) {
                    
                    Picker("Day/Night Mode", selection: $dayNightMode) {
                        Text("Auto").tag(DayNightMode.auto)
                        Text("Day").tag(DayNightMode.day)
                        Text("Night").tag(DayNightMode.night)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    if !animatedBackgrounds && !gradientBackground {
                        Toggle("Accent Color Based on Weather", isOn: $accentColorBasedOnWeather)
                    }
                    
                    Toggle("Minimalist Mode", isOn: $minimalistMode)

                    if animatedBackgrounds {
                        Text("Animated backgrounds are currently enabled.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Picker("Background Style", selection: $gradientBackground) {
                        Text("None").tag(false)
                        Text("Animated").tag(true)
                        Text("Gradient").tag(true)
                    }
                }

                Section(header: Text("Notifications")) {
                    Toggle("Storm Notifications", isOn: $stormNotifications)
                    Toggle("Air Quality Information", isOn: $airQuality)
                }

                Section(header: Text("Preferences")) {
                    Picker("Update Frequency", selection: $weatherUpdateFrequency) {
                        Text("15 Minutes").tag(UpdateFrequency.minutes15)
                        Text("30 Minutes").tag(UpdateFrequency.minutes30)
                        Text("Hourly").tag(UpdateFrequency.hourly)
                        Text("Daily").tag(UpdateFrequency.daily)
                    }
                
                }

                Section(header: Text("General")) {
                    Picker("Language", selection: $language) {
                        ForEach(Language.allCases, id: \.self) { lang in
                            Text(lang.rawValue).tag(lang)
                        }
                    }
                    
                    Toggle("Data Saving Mode", isOn: $dataSavingMode)
                }

                Section(header: Text("About")) {
                    NavigationLink("About the App") {
                         AboutView()
                    }
                    NavigationLink("Privacy Policy") {
                         PrivacyPolicyView()
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

enum City: String, Identifiable, CaseIterable {
    case newYork = "New York"
    case london = "London"
    case tokyo = "Tokyo"
    case paris = "Paris"
    case sydney = "Sydney"
    
    var id: String { self.rawValue }
    var name: String { self.rawValue }
}

enum DayNightMode: String, CaseIterable, Identifiable {
    case auto = "Auto"
    case day = "Day"
    case night = "Night"
    
    var id: String { self.rawValue }
}

#Preview {
    SettingsView()
}
