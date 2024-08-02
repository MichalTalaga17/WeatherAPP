import SwiftUI
import WeatherKit
import CoreLocation

struct ContentView: View {
    @StateObject private var geocodingViewModel = GeocodingViewModel()
    @State private var cityName: String = ""
    
    // Pobieranie wartości bezpośrednio z view modelu
    var lat: Double {
        geocodingViewModel.location?.coordinate.latitude ?? 0.0
    }
    
    var lon: Double {
        geocodingViewModel.location?.coordinate.longitude ?? 0.0
    }

    var body: some View {
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
            } else {
                if let location = geocodingViewModel.location {
                    Text("Latitude: \(lat)")
                    Text("Longitude: \(lon)")
                } else if let errorMessage = geocodingViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .navigationTitle("City to Coordinates")
    }
}

#Preview {
    ContentView()
}
