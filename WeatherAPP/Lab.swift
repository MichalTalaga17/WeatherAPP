import SwiftUI

struct Lab: View {
    let cityName: String
    @State private var weatherData: WeatherData?
    @State private var backgroundGradient = LinearGradient(gradient: Gradient(colors: [Color.black]), startPoint: .top, endPoint: .bottom)
    @State private var timeZone: TimeZone?
    
    var body: some View {
        VStack {
            if let weatherData = weatherData, let currentWeather = weatherData.list.first, let timeZone = timeZone {
                Spacer()
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .center, spacing: 5) {
                        HStack {
                            Spacer()
                            Text("\(weatherData.city.name)")
                                .font(.title3)
                            Spacer()
                        }
                        Text(kelvinToCelsius(currentWeather.main.temp))
                            .font(.system(size: 50))
                        Text(currentWeather.weather.first?.description ?? "")
                            .font(.headline)
                        Text("Od \(kelvinToCelsius(currentWeather.main.temp_min)) do \(kelvinToCelsius(currentWeather.main.temp_max))")
                            .font(.headline)
                    }
                    .padding()
                    
                    let containerWidth: CGFloat = UIScreen.main.bounds.width - 32
                    
                    HStack(spacing: 10) {
                        HStack(spacing: 30) {
                            VStack(alignment: .leading, spacing: 5) {
                                Image(systemName: "sunrise.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .yellow)
                                    .font(.title)
                                Text("\(formatDate(timestamp: weatherData.city.sunrise, formatType: .timeOnly, timeZone: timeZone))")
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                Image(systemName: "sunset.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .yellow)
                                    .font(.title)
                                Text("\(formatDate(timestamp: weatherData.city.sunset, formatType: .timeOnly, timeZone: timeZone))")
                            }
                        }
                        .padding()
                        .frame(width: containerWidth * 0.5 - 5, height: 100)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                        HStack{
                            Image(systemName: "eyeglasses")
                                .font(.title)
                            VStack {
                                Text("\(currentWeather.clouds.all)%")
                                Text("\(convertMetersToKilometers(meters: Double(currentWeather.visibility))) km")
                            }
                        }
                        .padding()
                        .frame(width: containerWidth * 0.5 - 5, height: 100)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Wilgotność: \(currentWeather.main.humidity)%")
                            Text("Ciśnienie: \(currentWeather.main.pressure) hPa")
                            Text("Prędkość wiatru: \(String(format: "%.0f", currentWeather.wind.speed)) m/s \(windDirection(from: currentWeather.wind.deg))")
                            Text("Opady deszczu: \(String(format: "%.0f", currentWeather.rain?.h1 ?? 0)) mm")
                            
                            if let snow = currentWeather.snow {
                                Text("Opady śniegu: \(snow.h1 ?? 0) mm")
                            }
                        }
                        .padding()
                        Spacer()
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            ForEach(weatherData.list.prefix(20), id: \.dt) { item in
                                VStack(alignment: .center) {
                                    if let timestamp = dateToTimestamp(dateString: item.dt_txt) {
                                        Text(formatDate(timestamp: Int(timestamp), formatType: .hourOnly, timeZone: timeZone))
                                            .font(.subheadline)
                                    } else {
                                        Text(item.dt_txt)
                                            .font(.subheadline)
                                    }
                                    weatherIcon(for: (item.weather.first?.icon)!)
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
                        .padding([.top, .bottom, .trailing])
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                    
                    Spacer()
                }
            } else {
                Spacer()
            }
            Spacer()
            HStack {
                Button {
                    print("Ulubione")
                } label: {
                    Text("Dodaj do ulubionych")
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(30)
                }
            }
            .padding(.bottom)
        }
        .padding()
        .background(backgroundGradient)
        .foregroundColor(.white)
        .onAppear {
            Task {
                await fetchWeatherData()
            }
        }
    }
    
    func fetchWeatherData() async {
        do {
            let _: () = try await API.shared.fetchWeatherData(forCity: cityName) { result in
                switch result {
                case .success(let data):
                    self.weatherData = data
                    if let currentWeather = data.list.first {
                        let newIcon = iconMap[currentWeather.weather.first?.icon ?? ""] ?? "unknown"
                        self.backgroundGradient = gradientBackground(for: newIcon)
                    }
                    self.timeZone = TimeZone(secondsFromGMT: data.city.timezone)
                case .failure(let error):
                    print("Błąd: \(error)")
                }
            }
        } catch {
            print("Błąd podczas pobierania danych: \(error)")
        }
    }
}

#Preview {
    Lab(cityName: "Nowy Jork")
}
