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
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                headerView
                cityListView
                Spacer()
            }
            .padding()
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.yellow.opacity(0.5), Color.blue.opacity(0.7)]),
                startPoint: .bottom,
                endPoint: .top
            ))
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private var headerView: some View {
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
                    print("")
                case .failure(let error):
                    showAlert(title: "Błąd", message: "Nie udało się pobrać danych o pogodzie: \(error.localizedDescription)")
                }
            }
        } catch {
            showAlert(title: "Błąd", message: "Nie udało się pobrać danych o pogodzie: \(error.localizedDescription)")
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(cities[index])
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.showAlert = true
    }
}



func kelvinToCelsius(_ kelvin: Double) -> Double {
    return kelvin - 273.15
}

func fetchCurrentWeatherData(forCity city: City, completion: @escaping (Result<CurrentResponse, Error>) -> Void) {
    let encodedCity = city.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&lang=pl&appid=e58dfbc15daacbeabeed6abc3e5d95ca"
    
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
