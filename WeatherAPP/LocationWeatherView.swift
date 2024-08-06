import SwiftUI

struct LocationWeatherView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
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
                    .padding(15)
                    
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
                        .padding(15)
                        .frame(width: containerWidth * 0.5 - 5, height: 100)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                        HStack(spacing: 20){
                            Image(systemName: "smoke.fill")
                                .font(.largeTitle)
                            VStack {
                                Text("\(currentWeather.clouds.all)%")
                                    .font(.title .bold())
                                Text("\(convertMetersToKilometers(meters: Double(currentWeather.visibility))) km")
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
                                    Text("\(currentWeather.main.humidity)%")
                                        .font(.title2 .bold())
                                    Text("Wilgotność")
                                }
                                .frame(width: containerWidth * 0.5-20)
                                Spacer()
                                VStack{
                                    Text("\(currentWeather.main.pressure) hPa")
                                        .font(.title2 .bold())
                                    Text("Ciśnienie")
                                }
                                .frame(width: containerWidth * 0.5-20)
                            }
                            HStack{
                                VStack{
                                    Text("\(String(format: "%.0f", currentWeather.wind.speed)) m/s \(windDirection(from: currentWeather.wind.deg))")
                                        .font(.title2 .bold())
                                    Text("Wiatr")
                                }
                                .frame(width: containerWidth * 0.5-20)
                                Spacer()
                                VStack{
                                    if let snow = currentWeather.snow {
                                        Text("\(String(format: "%.0f", snow.h1 ?? 0)) mm")
                                            .font(.title2 .bold())
                                        Text("Opady śniegu")
                                    }else{
                                        if let rain = currentWeather.rain {
                                            Text("\(String(format: "%.0f", rain.h1 ?? 0)) mm")
                                                .font(.title2 .bold())
                                            Text("Opady deszczu")
                                        }else{
                                            Text("\(String(format: "%.0f", currentWeather.rain?.h1 ?? 0)) mm")
                                                .font(.title2 .bold())
                                            Text("Opady deszczu")
                                        }
                                    }
                                    
                                }
                                .frame(width: containerWidth * 0.5-20)
                            }
                            
                            
                            
                        }
                        
                        .padding(.vertical)
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 5) {
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
                        
                        .padding(.vertical, 15.0)
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
                        .font(.caption)
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Wróć")
                        .font(.caption)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                }
                .foregroundColor(.white)
            }
        }
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
    LocationWeatherView(cityName: "Zembrzyce")
}
