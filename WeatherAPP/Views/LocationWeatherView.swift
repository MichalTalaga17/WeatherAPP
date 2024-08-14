import SwiftUI
import SwiftData
import UserNotifications

struct LocationWeatherView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cities: [City]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let cityName: String
    @State var favourite: Bool
    @State private var currentWeatherData: CurrentResponse?
    @State private var forecastData: ForecastData?
    @State private var backgroundGradient = LinearGradient(gradient: Gradient(colors: [Color.black]), startPoint: .top, endPoint: .bottom)
    @State private var timeZone: TimeZone?
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var airPollutionData: PollutionData?
    @State private var isLoading: Bool = true
    
    var body: some View {
        if isLoading {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .onAppear {
                    Task {
                        await loadData()
                    }
                }
        } else {
            VStack {
                if let currentWeatherData = currentWeatherData, let timeZone = timeZone {
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .center, spacing: 5) {
                            HStack {
                                Spacer()
                                Text("\(currentWeatherData.name), \(currentWeatherData.sys.country)")
                                    .font(.title3)
                                Spacer()
                            }
                            Text("\(Int(currentWeatherData.main.temp))°")
                                .font(.system(size: 60))
                            Text(currentWeatherData.weather.first?.description ?? "")
                                .font(.headline)
                            Text("From \(Int(currentWeatherData.main.temp_min))° to \(Int(currentWeatherData.main.temp_max))°")
                                .font(.callout)
                        }
                        .padding(15)
                        
                        let containerWidth: CGFloat = UIScreen.main.bounds.width - 32
                        
                        HStack(spacing: 10) {
                            HStack(spacing: 30) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Image(systemName: "sunrise.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, .yellow)
                                        .font(.title)
                                    Text("\(formatDate(timestamp: currentWeatherData.sys.sunrise, formatType: .timeOnly, timeZone: timeZone))")
                                }
                                VStack(alignment: .leading, spacing: 5) {
                                    Image(systemName: "sunset.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, .yellow)
                                        .font(.title)
                                    Text("\(formatDate(timestamp: currentWeatherData.sys.sunset, formatType: .timeOnly, timeZone: timeZone))")
                                }
                            }
                            .padding(15)
                            .frame(width: containerWidth * 0.5 - 5, height: 100)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(8)
                            HStack(spacing: 10){
                                if let firstWeather = currentWeatherData.weather.first {
                                    let icon = firstWeather.icon
                                    weatherIcon(for: icon)
                                        .font(.largeTitle)
                                }
                                
                                VStack {
                                    Text("\(currentWeatherData.clouds.all)%")
                                        .font(.title .bold())
                                    Text("\(convertMetersToKilometers(meters: Double(currentWeatherData.visibility))) km")
                                }
                            }
                            .padding()
                            .frame(width: containerWidth * 0.5 - 5, height: 100)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(8)
                        }
                        
                        HStack {
                            VStack(spacing: 15) {
                                HStack{
                                    VStack{
                                        Text("\(currentWeatherData.main.humidity)%")
                                            .font(.title2 .bold())
                                        Text("Humidity")
                                    }
                                    .frame(width: containerWidth * 0.5-20)
                                    Spacer()
                                    VStack{
                                        Text("\(currentWeatherData.main.pressure) hPa")
                                            .font(.title2 .bold())
                                        Text("Pressure")
                                    }
                                    .frame(width: containerWidth * 0.5-20)
                                }
                                HStack{
                                    VStack{
                                        Text("\(String(format: "%.0f", currentWeatherData.wind.speed)) m/s \(windDirection(from: currentWeatherData.wind.deg))")
                                            .font(.title2 .bold())
                                        Text("Wind")
                                    }
                                    .frame(width: containerWidth * 0.5-20)
                                    Spacer()
                                    VStack{
                                        if let snow = currentWeatherData.snow, let snow1h = snow.hour1 {
                                            Text("\(String(format: "%.0f", snow1h)) mm")
                                                .font(.title2.bold())
                                            Text("Snow")
                                        } else if let rain = currentWeatherData.rain, let rain1h = rain.hour1 {
                                            Text("\(String(format: "%.0f", rain1h)) mm")
                                                .font(.title2.bold())
                                            Text("Rain")
                                        } else {
                                            Text("0")
                                                .font(.title2.bold())
                                            Text("Precipitation")
                                        }
                                    }
                                    .frame(width: containerWidth * 0.5-20)
                                }
                            }
                            .padding(.vertical)
                        }
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                        
                        if let forecastData = forecastData {
                            ForecastScroll(data: forecastData, timezone: timeZone)
                        }
                        
                        HStack(spacing: 10) {
                            let containerWidth: CGFloat = UIScreen.main.bounds.width - 32
                            if let airPollutionData = airPollutionData, let airQuality = airPollutionData.list.first {
                                    
                                    HStack {
                                        VStack{
                                            Text("\(aqiDescription(for: airQuality.main.aqi))")
                                                .font(.title2 .bold())
                                            Text("Air Index")
                                                .font(.callout)
                                        }
                                        .padding(.leading, 25)
                                        .padding(.trailing, 15)
                                        ScrollView(.horizontal, showsIndicators: false){
                                            HStack(spacing: 30){
                                                
                                                VStack {
                                                    Text("\(Int(airQuality.components.pm2_5))")
                                                        .font(.title2 .bold())
                                                    Text("PM 2.5")
                                                        .font(.callout)
                                                }
                                                VStack {
                                                    Text("\(Int(airQuality.components.pm10))")
                                                        .font(.title2 .bold())
                                                    Text("PM 10")
                                                        .font(.callout)
                                                }
                                                VStack {
                                                    Text("\(Int(airQuality.components.co))")
                                                        .font(.title2 .bold())
                                                    Text("CO")
                                                        .font(.callout)
                                                }
                                                VStack {
                                                    Text("\(Int(airQuality.components.no))")
                                                        .font(.title2 .bold())
                                                    Text("NO")
                                                        .font(.callout)
                                                }
                                                VStack {
                                                    Text("\(Int(airQuality.components.pm2_5))")
                                                        .font(.title2 .bold())
                                                    Text("NO2")
                                                        .font(.callout)
                                                }
                                                VStack {
                                                    Text("\(Int(airQuality.components.o3))")
                                                        .font(.title2 .bold())
                                                    Text("O3")
                                                        .font(.callout)
                                                }
                                                VStack {
                                                    Text("\(Int(airQuality.components.so2))")
                                                        .font(.title2 .bold())
                                                    Text("SO2")
                                                        .font(.callout)
                                                }
                                                VStack {
                                                    Text("\(Int(airQuality.components.nh3))")
                                                        .font(.title2 .bold())
                                                    Text("NH3")
                                                        .font(.callout)
                                                }
                                                
                                                .padding(.trailing, 25)
                                            }
                                            .padding(0)
                                        }
                                    }
                                    .frame(width: containerWidth * 1, height: 80)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(8)
                                }
                        }
                        .padding(.bottom)
                    }
                } else {
                    Spacer()
                }
                Spacer()
            }
            .padding([.leading, .bottom, .trailing])
            .background(backgroundGradient)
            .foregroundColor(.white)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Back")
                            .font(.caption)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(20)
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .topBarTrailing){
                    if favourite {
                        Button {
                            if let city = cities.first(where: { $0.name == cityName }) {
                                modelContext.delete(city)
                                favourite.toggle()
                            }
                            if let userDefaults = UserDefaults(suiteName: "group.me.michaltalaga.WeatherAPP") {
                                userDefaults.removeObject(forKey: "City")
                            }
                        } label: {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(30)
                                .foregroundColor(.white)
                        }
                    } else {
                        Button {
                            let newCity = City(name: cityName)
                            do {
                                modelContext.insert(newCity)
                                try modelContext.save()
                                favourite.toggle()
                            } catch {
                                print("Error saving context: \(error)")
                            }
                        } label: {
                            Image(systemName: "star")
                                .font(.caption)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(30)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("Got it!")) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
        
    }
    
    private func showAlert(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.showAlert = true
    }
    
    func loadData() async {
        do {
            isLoading = true
            async let weatherResult = fetchCurrentWeatherData()
            async let forecastResult = fetchWeatherData()
            async let airPollutionResult = fetchAirPollutionData()
            
            try await (weatherResult, forecastResult, airPollutionResult)
            isLoading = false
        } catch {
            showAlert(title: "Error", message: "Cannot fetch data")
            print("\(error.localizedDescription)")
        }
    }
    
    func fetchAirPollutionData() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            API.shared.fetchAirPollutionData(forCity: cityName) { result in
                switch result {
                case .success(let data):
                    self.airPollutionData = data
                    continuation.resume(returning: ())
                case .failure(let error):
                    showAlert(title: "Error", message: "Cannot fetch air pollution data")
                    print("\(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func fetchWeatherData() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            API.shared.fetchForecastData(forCity: cityName) { result in
                switch result {
                case .success(let data):
                    self.forecastData = data
                    self.timeZone = TimeZone(secondsFromGMT: data.city.timezone)
                    continuation.resume(returning: ())
                case .failure(let error):
                    showAlert(title: "Error", message: "Cannot fetch data")
                    print("\(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func fetchCurrentWeatherData() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            API.shared.fetchCurrentWeatherData(forCity: cityName) { result in
                switch result {
                case .success(let data):
                    self.currentWeatherData = data
                    let newIcon = data.weather.first?.icon ?? "unknown"
                    self.backgroundGradient = gradientBackground(for: newIcon)
                    self.timeZone = TimeZone(secondsFromGMT: data.timezone)
                    continuation.resume(returning: ())
                case .failure(let error):
                    showAlert(title: "Error", message: "Cannot fetch data")
                    print("\(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    struct ForecastScroll: View {
        let data: ForecastData
        let timezone: TimeZone
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 5) {
                    ForEach(Array(data.list.prefix(20)), id: \.dt) { item in
                        VStack(alignment: .center) {
                            if let timestamp = dateToTimestamp(dateString: item.dt_txt) {
                                Text(formatDate(timestamp: Int(timestamp), formatType: .hourOnly, timeZone: timezone))
                                    .font(.subheadline)
                            } else {
                                Text(item.dt_txt)
                                    .font(.subheadline)
                            }
                            weatherIcon(for: item.weather.first?.icon ?? "defaultIcon")
                            Text(kelvinToCelsius(item.main.temp))
                                .font(.title2.bold())
                            Text(kelvinToCelsius(item.main.feels_like))
                                .font(.body)
                            Text("\(String(format: "%.0f", item.pop * 100))%")
                                .font(.body)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.25)
                    }
                }
                .padding(.vertical, 15.0)
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
        }
    }
}

#Preview {
    LocationWeatherView(cityName: "Zembrzyce", favourite: true)
        .modelContainer(for: City.self)
}
