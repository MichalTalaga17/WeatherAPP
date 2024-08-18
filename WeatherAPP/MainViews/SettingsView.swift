//
//  SettingsView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("units") private var units: Units = .metric
    @AppStorage("iconsColorsBasedOnWeather") private var iconsColorsBasedOnWeather: Bool = false
    @AppStorage("animatedBackgrounds") private var animatedBackgrounds: Bool = false
    @AppStorage("gradientBackground") private var gradientBackground: Bool = false
    @AppStorage("stormNotifications") private var stormNotifications: Bool = true
    @AppStorage("airQuality") private var airQuality: Bool = true
    @AppStorage("dataSavingMode") private var dataSavingMode: Bool = false
    @AppStorage("language") private var language: Language = .english
    @AppStorage("weatherUpdateFrequency") private var weatherUpdateFrequency: UpdateFrequency = .hourly
    @AppStorage("defaultCity") private var defaultCity: String = "New York"
    
    private let cities: [City] = [.newYork, .london, .tokyo, .paris, .sydney]
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Menu {
                        ForEach(cities) { city in
                            Button(action: {
                                defaultCity = city.name
                            }) {
                                Text(city.name)
                            }
                        }
                    } label: {
                        HStack {
                            Text("Default City:")
                            Spacer()
                            Text("\(defaultCity)")
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                    // Units Picker
                    Menu {
                        ForEach(Units.allCases) { unit in
                            Button(action: {
                                units = unit
                            }) {
                                Text(unit.rawValue.capitalized)
                            }
                        }
                    } label: {
                        HStack {
                            Text("Temperature Units: \(units.rawValue.capitalized)")
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                    // Appearance Section
                    Section(header: Text("Appearance").font(.headline)) {
                        CustomToggle(isOn: $iconsColorsBasedOnWeather, label: "Icons Colors Based on Weather")
                        
                        CustomToggle(isOn: $animatedBackgrounds, label: "Animated Backgrounds")
                        
                        Menu {
                            Button(action: {
                                gradientBackground = false
                            }) {
                                Text("None")
                            }
                            Button(action: {
                                gradientBackground = true
                            }) {
                                Text("Gradient")
                            }
                        } label: {
                            HStack {
                                Text("Background Style: \(gradientBackground ? "Gradient" : "None")")
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Notifications Section
                    Section(header: Text("Notifications").font(.headline)) {
                        CustomToggle(isOn: $stormNotifications, label: "Storm Notifications")
                        CustomToggle(isOn: $airQuality, label: "Air Quality Information")
                    }
                    
                    // Preferences Section
                    Menu {
                        ForEach(UpdateFrequency.allCases) { frequency in
                            Button(action: {
                                weatherUpdateFrequency = frequency
                            }) {
                                Text(frequency.rawValue)
                            }
                        }
                    } label: {
                        HStack {
                            Text("Widgets Update Frequency: \(weatherUpdateFrequency.rawValue)")
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                    // Language Menu
                    Menu {
                        ForEach(Language.allCases) { lang in
                            Button(action: {
                                language = lang
                            }) {
                                Text(lang.rawValue)
                            }
                        }
                    } label: {
                        HStack {
                            Text("Language: \(language.rawValue)")
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                    // Data Saving Mode Toggle
                    CustomToggle(isOn: $dataSavingMode, label: "Data Saving Mode")
                }
                .padding()
            }
        }
    }
}

struct CustomToggle: View {
    @Binding var isOn: Bool
    let label: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Button(action: {
                isOn.toggle()
            }) {
                Text(isOn ? "On" : "Off")
                    .padding()
                    .background(isOn ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical)
    }
}

enum Units: String, Identifiable, CaseIterable {
    case metric = "metric"
    case imperial = "imperial"
    
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

#Preview {
    SettingsView()
}
