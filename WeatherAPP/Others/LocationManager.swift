import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocationCoordinate2D?
    @Published var cityName: String? = "Unknown"
    
    private var manager: CLLocationManager?
    
    override init() {
        super.init()
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        manager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.location = location.coordinate
            reverseGeocode(location: location)
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    private func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Failed to reverse geocode location: \(error.localizedDescription)")
                self.cityName = "Unknown"
                return
            }
            
            if let placemark = placemarks?.first {
                self.cityName = placemark.locality ?? "Unknown"
                self.saveCityName(self.cityName ?? "Unknown")
            }
        }
    }
    
    func saveCityName(_ cityName: String) {
        let defaults = UserDefaults.standard
        defaults.set(cityName, forKey: "cityName")
    }
    
    func loadCityName() -> String? {
        let defaults = UserDefaults.standard
        let cityName = defaults.string(forKey: "cityName")
        print("Loaded City Name: \(cityName ?? "None")") // Debug line
        return cityName
    }
    
    func saveLocation(_ coordinate: CLLocationCoordinate2D) {
        let defaults = UserDefaults.standard
        defaults.set(coordinate.latitude, forKey: "latitude")
        defaults.set(coordinate.longitude, forKey: "longitude")
    }
    
    func loadLocation() -> CLLocationCoordinate2D? {
        let defaults = UserDefaults.standard
        guard let latitude = defaults.value(forKey: "latitude") as? Double,
              let longitude = defaults.value(forKey: "longitude") as? Double else { return nil }
        print("Loaded Location: Latitude \(latitude), Longitude \(longitude)") // Debug line
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
