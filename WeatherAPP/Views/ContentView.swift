import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cities: [City]
    @State private var cityName = ""
    @State private var cityName2 = ""
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var currentWeatherData: CurrentResponse?
    
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                VStack {
                    Text("Pogoda")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 10) {
                        TextField("Podaj miasto", text: $cityName)
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                        
                        NavigationLink(destination: LocationWeatherView(cityName: cityName2, favourite: false)) {
                            Text("Szukaj")
                                .font(.callout)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            cityName2 = cityName
                            cityName = ""
                        })
                    }
                }
                .padding(.bottom, 40)
                    ForEach(cities) { item in
                        NavigationLink(destination: LocationWeatherView(cityName: item.name, favourite: true)) {
                            await fetchCurrentWeatherData()
                            Text(item.name)
                            Spacer()
                        }
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundStyle(Color.white)
                        
                    }
                    .onDelete(perform: deleteItems)
                    .background(Color.white.opacity(0))
                Spacer()
            }
            .padding()
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.yellow.opacity(0.5), Color.blue.opacity(0.7)]),
                startPoint: .bottom,
                endPoint: .top
            ))
            
            
        }
        
    }
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(cities[index])
            }
        }
    }
    func fetchCurrentWeatherData() async {
        do {
            print(cityName)
            try await API.shared.fetchCurrentWeatherData(forCity: cityName) { result in
                switch result {
                case .success(let data):
                    self.currentWeatherData = data
                    let newIcon = data.weather.first?.icon ?? "unknown"
                    self.backgroundGradient = gradientBackground(for: newIcon)
                    self.timeZone = TimeZone(secondsFromGMT: data.timezone)
                case .failure(let error):
                    showAlert(title: "Błąd", message: "Nie udało się pobrać danych o pogodzie: \(error.localizedDescription)")
                }
            }
        } catch {
            showAlert(title: "Błąd", message: "Nie udało się pobrać danych o pogodzie: \(error.localizedDescription)")
        }
    }
    
    
}


#Preview {
    ContentView()
        .modelContainer(for: City.self, inMemory: true)
}
