import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var geocodingViewModel = GeocodingViewModel()
    @State private var cityName: String = ""
    @State private var isShowingWeatherView: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter city name", text: $cityName)
                        .padding()
                        .background(Color.white)
                        .border(Color.black, width: 1)
                        .frame(maxWidth: .infinity)

                    Button("Get") {
                        Task {
                            await geocodingViewModel.geocode(cityName: cityName)
                            if geocodingViewModel.location != nil {
                                isShowingWeatherView = true
                            }
                        }
                    }
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .frame(width: 80) 
                }
                .padding()

                Spacer()

                if geocodingViewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = geocodingViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .navigationTitle("City to Coordinates")
            .background(
                NavigationLink(
                    destination: WeatherView(location: geocodingViewModel.location ?? CLLocation()),
                    isActive: $isShowingWeatherView
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }
}

#Preview {
    ContentView()
}
