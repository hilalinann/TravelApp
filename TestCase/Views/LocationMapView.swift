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
        ZStack(alignment: .bottomTrailing) {
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: getAnnotations()) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Circle()
                        .fill(item.color)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                            .font(.system(size: 22))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
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
            
            Button(action: {
                handleLocationButtonTapped()
            }) {
                Image(systemName: "location.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    .padding(.trailing, 20)
                    .padding(.bottom, 140)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            checkLocationAuthorization()
        }
        .onChange(of: locationManager.location) { newLocation in
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
    
    private func handleLocationButtonTapped() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if let userLocation = locationManager.location {
                region = MKCoordinateRegion(
                    center: userLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            } else {
                locationManager.requestLocation()
            }
        case .notDetermined:
            showingLocationAlert = true
        case .restricted, .denied:
            showingSettingsAlert = true
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
    
    private func getAnnotations() -> [LocationPin] {
        var annotations: [LocationPin] = []
        
        if let userLocation = userLocation {
            annotations.append(LocationPin(coordinate: userLocation.coordinate, title: "Benim Konumum", color: .blue))
        }
        
        let cityLocation = LocationPin(
            coordinate: CLLocationCoordinate2D(latitude: location.coordinates.lat, longitude: location.coordinates.lng),
            title: location.name,
            color: .green
        )
        annotations.append(cityLocation)
        
        return annotations
    }
}

struct UserLocation: Identifiable, Equatable {
    var id = UUID()
    var coordinate: CLLocationCoordinate2D
    
    static func == (lhs: UserLocation, rhs: UserLocation) -> Bool {
        lhs.id == rhs.id
    }
}

enum MapApp {
    case apple, google, yandex
}

