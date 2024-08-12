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
        .onDelete(perform: deleteItems)
        .background(Color.white.opacity(0))
    }
    
    private func fetchWeatherData(for city: City) async {
        do {
            try await fetchCurrentWeatherData(forCity: city) { result in
                switch result {
                case .success(let data):
                    if city.id == cities.first?.id, let icon = data.weather.first?.icon {
                        self.backgroundGradient = gradientBackground(for: icon)
                    }
                case .failure(let error):
                    showAlert(title: "Error", message: "Cannot fetch data")
                }
            }
        } catch {
            showAlert(title: "Error", message: "Cannot fetch data")
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(cities[index])
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


func fetchCurrentWeatherData(forCity city: City, completion: @escaping (Result<CurrentResponse, Error>) -> Void) {
    let encodedCity = city.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(API.key)"
    
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
            return
        }
        
        do {
            let currentWeatherData = try JSONDecoder().decode(CurrentResponse.self, from: data)
            DispatchQueue.main.async {
                city.temperature = currentWeatherData.main.temp
                city.weatherIcon = currentWeatherData.weather.first?.icon
                completion(.success(currentWeatherData))
            }
        } catch {
            completion(.failure(error))
        }
        
    }.resume()
    
}

#Preview {
    ContentView()
        .modelContainer(for: City.self, inMemory: true)
}
