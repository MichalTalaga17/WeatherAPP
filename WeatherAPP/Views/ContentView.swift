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
    @State private var backgroundGradient: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [Color.yellow.opacity(0.5), Color.blue.opacity(0.7)]),
        startPoint: .bottom,
        endPoint: .top
    )
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationView {
            
            VStack(alignment: .leading) {
                NavigationLink(destination: SettingsView()) {
                                    Text("Settings")
                                        .font(.headline)
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .padding()
                headerView
                cityListView
                Spacer()
            }
            .padding()
            .background(backgroundGradient)
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                updateBackgroundGradient()
                if let userDefaults = UserDefaults(suiteName: "group.me.michaltalaga.WeatherAPP"){
                    var id = cities.first?.id
                    userDefaults.set(cities.first?.name, forKey: "City")
                }
                locationManager.requestLocation()
            }
            
        }
    }
    
    private var headerView: some View {
        VStack {
            Text("WeatherAPP")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            HStack(spacing: 10) {
                TextField("Search for city", text: $cityName)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(8)
                
                NavigationLink(destination: LocationWeatherView(cityName: cityName2, favourite: false)) {
                    Image(systemName: "magnifyingglass")                        .font(.callout)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    cityName2 = cityName
                    cityName = ""
                })
                if let liveCityName = locationManager.cityName {
                    NavigationLink(destination: LocationWeatherView(cityName: liveCityName, favourite: false)) {
                        Image(systemName: "location.fill")
                            .font(.callout)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
            }
        }
        .padding(.bottom, 40)
    }
    
    
    private var cityListView: some View {
        ForEach(cities) { city in
            CityRowView(city: city)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(8)
                .foregroundStyle(Color.white)
                .task {
                    await fetchWeatherData(for: city)
                }
        }
        .background(Color.white.opacity(0))
    }
    
    private func fetchWeatherData(for city: City) async {
        API.shared.fetchCurrentWeatherData(forCity: city.name) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    city.temperature = data.main.temp
                    city.weatherIcon = data.weather.first?.icon
                    if city.id == cities.first?.id, let icon = data.weather.first?.icon {
                        self.backgroundGradient = gradientBackground(for: icon)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    showAlert(title: "Error", message: "Cannot fetch data")
                }
            }
        }
    }
    
    private func updateBackgroundGradient() {
        if let firstCity = cities.first, let icon = firstCity.weatherIcon {
            self.backgroundGradient = gradientBackground(for: icon)
        }
    }
    
    func showAlert(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.showAlert = true
    }
}

#Preview {
    ContentView()
        .modelContainer(for: City.self, inMemory: true)
}
