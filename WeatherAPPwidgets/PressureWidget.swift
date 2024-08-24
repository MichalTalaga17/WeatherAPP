//
//  PressureWidget.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 24/08/2024.
//

import SwiftUI
import WidgetKit
import CoreLocation

// MARK: - PressureWidget Entry
/// Struktura przechowująca dane dla widgetu.
struct PressureWidgetEntry: TimelineEntry {
    var date: Date
    
    let cityName: String
    let pressure: String
}

// MARK: - PressureWidget Provider
/// Provider dostarczający dane dla widgetu.
struct PressureWidgetProvider: TimelineProvider {
    @ObservedObject private var locationManager = LocationManager()
    private let api = API.shared
    
    /// Funkcja zwracająca dane przykładowe dla widoku w trybie podglądu.
    func placeholder(in context: Context) -> PressureWidgetEntry {
        PressureWidgetEntry(
            date: Date(),
            cityName: "Nieznane",
            pressure: "-- hPa"
        )
    }
    
    /// Funkcja zwracająca dane dla widoku w trybie podglądu.
    func getSnapshot(in context: Context, completion: @escaping (PressureWidgetEntry) -> Void) {
        fetchPressure { pressure, cityName in
            let entry = PressureWidgetEntry(
                date: Date(),
                cityName: cityName,
                pressure: pressure
            )
            completion(entry)
        }
    }
    
    /// Funkcja zwracająca dane dla harmonogramu widgetu.
    func getTimeline(in context: Context, completion: @escaping (Timeline<PressureWidgetEntry>) -> Void) {
        fetchPressure { pressure, cityName in
            let entry = PressureWidgetEntry(
                date: Date(),
                cityName: cityName,
                pressure: pressure
            )
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    /// Funkcja pobierająca ciśnienie atmosferyczne.
    private func fetchPressure(completion: @escaping (String, String) -> Void) {
        locationManager.requestLocation { result in
            switch result {
            case .success(let location):
                print("Lokalizacja pobrana pomyślnie: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                
                if locationManager.cityName != "Unknown" {
                    print("Nazwa miasta pobrana pomyślnie: \(locationManager.cityName)")
                    
                    api.fetchCurrentWeatherData(forCity: locationManager.cityName) { result in
                        switch result {
                        case .success(let data):
                            let pressure = "\(data.main.pressure) hPa"
                            print("Ciśnienie pobrane pomyślnie: \(pressure)")
                            completion(pressure, locationManager.cityName)
                        case .failure(let error):
                            print("Nie udało się pobrać danych pogodowych: \(error.localizedDescription)")
                            completion("-- hPa", locationManager.cityName)
                        }
                    }
                } else {
                    print("Nazwa miasta jest nieznana, nie można pobrać danych pogodowych.")
                    completion("-- hPa", "Nieznane")
                }
                
            case .failure(let error):
                print("Nie udało się pobrać lokalizacji: \(error.localizedDescription)")
                completion("-- hPa", "Nieznane")
            }
        }
    }
}

// MARK: - PressureWidget View
/// Widok dla widgetu, wyświetlający nazwę miasta i ciśnienie atmosferyczne.
struct PressureWidgetEntryView: View {
    var entry: PressureWidgetEntry
    
    // Convert pressure string to a double for the gauge
    private var pressureValue: Double {
        Double(entry.pressure.replacingOccurrences(of: " hPa", with: "")) ?? 1015
    }
    
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text(entry.cityName)
                    .font(.headline)
                Spacer()
                    VStack(alignment: .leading){
                        Text("\(Int(pressureValue))")
                            .font(.title .bold())
                        Text("hPa")
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color.accentColor.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Spacer()
        }
    }
}

// MARK: - PressureWidget Configuration
/// Konfiguracja widgetu, w tym jego wyświetlana nazwa i opis.
struct PressureWidget: Widget {
    let kind: String = "PressureWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PressureWidgetProvider()) { entry in
            PressureWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Widget ciśnienia atmosferycznego")
        .description("Wyświetla aktualne ciśnienie atmosferyczne i nazwę miasta.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Preview
/// Podgląd widgetu w trybie edycji.
#Preview(as: .systemSmall) {
    PressureWidget()
} timeline: {
    PressureWidgetEntry(date: Date(), cityName: "Warszawa", pressure: "1015 hPa")
}
