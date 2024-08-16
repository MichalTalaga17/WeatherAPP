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
    @AppStorage("animatedBackgrounds") private var animatedBackgrounds: Bool = true
    @AppStorage("stormNotifications") private var stormNotifications: Bool = true
    @AppStorage("airQuality") private var airQuality: Bool = true
    @AppStorage("dataSavingMode") private var dataSavingMode: Bool = false
    @AppStorage("language") private var language: Language = .english
    @AppStorage("dayNightMode") private var dayNightMode: Bool = true
    @AppStorage("autoLocationDetection") private var autoLocationDetection: Bool = true
    @AppStorage("windSpeedUnits") private var windSpeedUnits: WindSpeedUnits = .kilometersPerHour
    @AppStorage("weatherUpdateFrequency") private var weatherUpdateFrequency: UpdateFrequency = .hourly
    @AppStorage("defaultCity") private var defaultCity: String = "New York"

    var body: some View {
        NavigationView {
            Form {
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
                    Toggle("Accent Color Based on Weather", isOn: $accentColorBasedOnWeather)
                    Toggle("Minimalist Mode", isOn: $minimalistMode)
                    Toggle("Animated Backgrounds", isOn: $animatedBackgrounds)
                    Toggle("Day/Night Mode", isOn: $dayNightMode)
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
                    
                    Toggle("Auto Location Detection", isOn: $autoLocationDetection)
                    
                    TextField("Default City", text: $defaultCity)
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

#Preview {
    SettingsView()
}
