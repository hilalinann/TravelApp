import SwiftUI
import MapKit
import CoreLocation

struct LocationMapView: View {
    let location: CityLocation
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @State private var region: MKCoordinateRegion
    @State private var showingDirectionsAlert = false
    @State private var showingLocationAlert = false
    @State private var showingSettingsAlert = false
    @State private var userLocation: UserLocation?

    struct LocationPin: Identifiable {
        var id = UUID()
        var coordinate: CLLocationCoordinate2D
        var title: String
        var color: Color
    }

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
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: getAnnotations()) { item in
                // MapAnnotation ile özel marker ekliyoruz
                MapAnnotation(coordinate: item.coordinate) {
                    Circle()
                        .fill(item.color)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
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
            checkLocationAuthorization()
        }
        .onChange(of: locationManager.location) { newLocation in
            // Konum güncellendiğinde
            if let newLocation = newLocation {
                userLocation = UserLocation(coordinate: newLocation.coordinate)
                region = MKCoordinateRegion(
                    center: newLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
        .alert("Kendi konumunu haritada görmek ister misin?", isPresented: $showingLocationAlert) {
            Button("Evet") {
                locationManager.requestLocation()
            }
            Button("Hayır", role: .cancel) { }
        }
        .alert("Konum İzni Gerekli", isPresented: $showingSettingsAlert) {
            Button("Ayarlara Git") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("İptal", role: .cancel) { }
        } message: {
            Text("Konumunuzu görebilmek için ayarlardan konum iznini etkinleştirmeniz gerekmektedir.")
        }
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            showingLocationAlert = true
        case .restricted, .denied:
            showingSettingsAlert = true
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        @unknown default:
            break
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

    // Bu fonksiyon, harita üzerinde gösterilecek pin'leri döndürür
    private func getAnnotations() -> [LocationPin] {
        var annotations: [LocationPin] = []

        // Kullanıcının konumunu mavi pinle ekliyoruz
        if let userLocation = userLocation {
            annotations.append(LocationPin(coordinate: userLocation.coordinate, title: "Benim Konumum", color: .blue))
        }

        // Seçilen şehir konumunu yeşil pinle ekliyoruz
        let cityLocation = LocationPin(
            coordinate: CLLocationCoordinate2D(latitude: location.coordinates.lat, longitude: location.coordinates.lng),
            title: location.name,
            color: .green
        )
        annotations.append(cityLocation)

        return annotations
    }
}

struct UserLocation: Identifiable {
    var id = UUID()
    var coordinate: CLLocationCoordinate2D
}

enum MapApp {
    case apple, google, yandex
}

