import SwiftUI
import MapKit
import CoreLocation

struct LocationMapView: View {
    let location: CityLocation
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @State private var region: MKCoordinateRegion
    @State private var showingDirectionsAlert = false
    
    init(location: CityLocation) {
        self.location = location
        let coordinate = CLLocationCoordinate2D(
            latitude: location.coordinates.lat,
            longitude: location.coordinates.lng
        )
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Full screen map
            Map(coordinateRegion: $region, annotationItems: [location]) { location in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: location.coordinates.lat,
                    longitude: location.coordinates.lng
                )) {
                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundColor(.yellow)
                        .background(
                            Circle()
                                .fill(.white)
                                .frame(width: 40, height: 40)
                        )
                        .shadow(radius: 2)
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            // Content overlay
            VStack(spacing: 0) {
                // Top navigation bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                            .font(.system(size: 22))
                    }
                    
                    Spacer()
                    
                    Text(location.name.uppercased())
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                Spacer()
                
                // Directions button
                Button {
                    showingDirectionsAlert = true
                } label: {
                    Text("Yol Tarifi Al")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .actionSheet(isPresented: $showingDirectionsAlert) {
                    ActionSheet(
                        title: Text("Yol Tarifi"),
                        message: Text("Hangi uygulama ile yol tarifi almak istersiniz?"),
                        buttons: [
                            .default(Text("Apple Maps")) {
                                openInMaps(using: .apple)
                            },
                            .default(Text("Google Maps")) {
                                openInMaps(using: .google)
                            },
                            .default(Text("Yandex Maps")) {
                                openInMaps(using: .yandex)
                            },
                            .cancel(Text("İptal"))
                        ]
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            locationManager.requestLocation()
        }
    }
    
    private func openInMaps(using app: MapApp) {
        guard let userLocation = locationManager.location else {
            return
        }
        
        let destinationCoordinate = "\(location.coordinates.lat),\(location.coordinates.lng)"
        let sourceCoordinate = "\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)"
        
        var urlString: String
        
        switch app {
        case .apple:
            urlString = "http://maps.apple.com/?saddr=\(sourceCoordinate)&daddr=\(destinationCoordinate)"
        case .google:
            urlString = "comgooglemaps://?saddr=\(sourceCoordinate)&daddr=\(destinationCoordinate)&directionsmode=driving"
            if !UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                urlString = "https://www.google.com/maps/dir/?api=1&origin=\(sourceCoordinate)&destination=\(destinationCoordinate)"
            }
        case .yandex:
            urlString = "yandexmaps://maps.yandex.com/?rtext=\(sourceCoordinate)~\(destinationCoordinate)"
            if !UIApplication.shared.canOpenURL(URL(string: "yandexmaps://")!) {
                urlString = "https://yandex.com/maps/?rtext=\(sourceCoordinate)~\(destinationCoordinate)"
            }
        }
        
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

enum MapApp {
    case apple, google, yandex
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
} 