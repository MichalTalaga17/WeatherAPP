import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var geocodingViewModel = GeocodingViewModel()
    @State private var cityName: String = ""
    @State private var selectedLocation: CLLocation? = nil

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
                            if let location = geocodingViewModel.location {
                                selectedLocation = location
                            }
                        }
                    }
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .frame(width: 80) // Ustaw szerokość przycisku
                }
                .padding()

                Spacer()

                if geocodingViewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = geocodingViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                NavigationLink(
                    destination: WeatherView(location: selectedLocation ?? CLLocation()),
                    isActive: Binding(
                        get: { selectedLocation != nil },
                        set: { _ in }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .padding()
            .navigationTitle("City to Coordinates")
        }
    }
}

#Preview {
    ContentView()
}
