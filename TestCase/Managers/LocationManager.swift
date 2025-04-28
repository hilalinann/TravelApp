import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var userLocation: UserLocation?
    
    override init() {
        // Başlangıçta authorizationStatus değeri
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Konum isteğini başlatmak için bir fonksiyon
    func requestLocation() {
        // Eğer izin verilmemişse, izin iste
        if CLLocationManager.locationServicesEnabled() {
            switch authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                // Kullanıcı izin vermemişse veya kısıtlama varsa
                print("Konum izni reddedildi.")
            case .authorizedWhenInUse, .authorizedAlways:
                // İzin verilmişse konum al
                locationManager.requestLocation()
            @unknown default:
                break
            }
        }
    }
    
    // Konum güncellemeleri alındığında çağrılır
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
        if let location = locations.first {
            userLocation = UserLocation(coordinate: location.coordinate)
        }
    }
    
    // Konum alımında bir hata oluştuğunda çağrılır
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum hatası: \(error.localizedDescription)")
    }
    
    // Konum izni durumu değiştiğinde çağrılır
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}

