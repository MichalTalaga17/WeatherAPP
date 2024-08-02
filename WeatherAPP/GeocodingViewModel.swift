import Foundation
import CoreLocation

@MainActor
class GeocodingViewModel: NSObject, ObservableObject {
    private let geocoder = CLGeocoder()
    @Published var location: CLLocation?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    func geocode(cityName: String) async {
        guard !cityName.isEmpty else {
            self.errorMessage = "City name cannot be empty."
            return
        }

        self.isLoading = true
        self.errorMessage = nil

        do {
            let placemarks = try await geocoder.geocodeAddressString(cityName)
            if let location = placemarks.first?.location {
                self.location = location
            } else {
                self.errorMessage = "No location found for city: \(cityName)"
                self.location = nil
            }
        } catch {
            self.errorMessage = "Geocoding error: \(error.localizedDescription)"
        }

        self.isLoading = false
    }
}
