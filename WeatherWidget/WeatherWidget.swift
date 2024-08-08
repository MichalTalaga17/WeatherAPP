import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let city: String
    let temperature: String
    let weatherCondition: String
}

struct Provider: TimelineProvider {
    //co pokazuje przy generowaniu
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), city: "Miasto", temperature: "20°C", weatherCondition: "Chmury")
    }
    //co pokazuje w galeri wiżetów
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), city: "Warszawa", temperature: "18°C", weatherCondition: "Słonecznie")
        completion(entry)
    }
    //co generuje
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []

        if let userDefaults = UserDefaults(suiteName: "group.me.michaltalaga.WeatherAPP") {
            print(userDefaults.string(forKey: "City"))
            let city = userDefaults.string(forKey: "City") ?? "Nieznane"
            let temperature = userDefaults.string(forKey: "Temperature") ?? "0°C"
            let weatherCondition = userDefaults.string(forKey: "WeatherCondition") ?? "Brak danych"

            let entry = SimpleEntry(date: .now, city: city, temperature: temperature, weatherCondition: weatherCondition)
            entries.append(entry)
        } else {
            let entry = SimpleEntry(date: .now, city: "Domyślne Miasto", temperature: "0°C", weatherCondition: "Brak danych")
            entries.append(entry)
        }

        // Zwrócenie całego harmonogramu za pomocą completion
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct WeatherWidgetEntryView: View {
    var entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.city)
                .font(.headline)
            Spacer()
            HStack {
                Text(entry.temperature)
                    .font(.title)
                
                Text(entry.weatherCondition)
            }
        }
        .padding()
        .background(Color.red.opacity(0.2))
        .cornerRadius(8)
    }
}

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Widget Pogody")
        .description("Wyświetla aktualne informacje o pogodzie.")
    }
}

#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    SimpleEntry(date: .now, city: "Zembrzyce", temperature: "20°C", weatherCondition: "Chmury")
}
