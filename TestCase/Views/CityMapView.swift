import SwiftUI
import MapKit
import CoreLocation

struct CityMapView: View {
    let city: City
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    @State private var selectedLocation: CityLocation?
    @State private var showingDetail = false
    @StateObject private var locationManager = LocationManager()  // locationManager'ı StateObject olarak başlattık
    @State private var userLocation: UserLocation?
    @State private var showingLocationAlert = false
    @State private var showingSettingsAlert = false
    @State private var isFollowingUser = false
    @State private var buttonOffset: CGFloat = 0

    init(city: City) {
        self.city = city
        if let firstLocation = city.locations.first {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: firstLocation.coordinates.lat,
                    longitude: firstLocation.coordinates.lng
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        } else {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 39.9334, longitude: 32.8597),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Harita
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: sortedLocations()) { location in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: location.coordinates.lat,
                    longitude: location.coordinates.lng
                )) {
                    if location.id == city.locations.first?.id {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                            .background(Circle().fill(Color(uiColor: .systemBackground)).frame(width: 44, height: 44))
                            .shadow(radius: 2)
                    } else if location.id == selectedLocation?.id {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.blue)
                            .background(Circle().fill(Color(uiColor: .systemBackground)).frame(width: 48, height: 48))
                            .shadow(radius: 3)
                    } else {
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundColor(.yellow)
                            .background(Circle().fill(Color(uiColor: .systemBackground)).frame(width: 40, height: 40))
                            .shadow(radius: 2)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        buttonOffset = value.translation.height
                    }
                    .onEnded { value in
                        withAnimation(.spring()) {
                            buttonOffset = 0
                        }
                    }
            )

            // Üstteki başlık
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Theme.textColor)
                        .font(.system(size: 22))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }

                Spacer()

                Text(city.name.uppercased())
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.textColor)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .background(Color.clear)

            // Konum butonu
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button {
                        handleLocationButtonTap()
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .padding(.trailing, 16)
                    .offset(y: buttonOffset)
                    .animation(.spring(), value: buttonOffset)
                }
                .padding(.bottom, 20)
                
                // Konumlar listesi
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(sortedLocations()) { location in
                            LocationCard(location: location, selectedLocation: $selectedLocation, userLocation: userLocation)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 200)
                .background(Color.clear)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            checkLocationAuthorization()
        }
        .onChange(of: locationManager.userLocation) { newLocation in
            if let location = newLocation, isFollowingUser {
                withAnimation {
                    region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
            }
        }
        .alert("Kendi konumunu haritada görmek ister misin?", isPresented: $showingLocationAlert) {
            Button("Evet") {
                locationManager.requestLocation()
                isFollowingUser = true
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

    private func handleLocationButtonTap() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            showingLocationAlert = true
        case .restricted, .denied:
            showingSettingsAlert = true
        case .authorizedWhenInUse, .authorizedAlways:
            isFollowingUser.toggle()
            if isFollowingUser {
                locationManager.requestLocation()
            }
        @unknown default:
            break
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

    private func sortedLocations() -> [CityLocation] {
        // Eğer kullanıcı konumunu paylaştıysa, yakınlığa göre sıralama yapılır
        guard let userLocation = locationManager.userLocation else {
            return city.locations
        }

        return city.locations.sorted { location1, location2 in
            let loc1 = CLLocation(latitude: location1.coordinates.lat, longitude: location1.coordinates.lng)
            let loc2 = CLLocation(latitude: location2.coordinates.lat, longitude: location2.coordinates.lng)
            let userLoc = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            
            let distance1 = userLoc.distance(from: loc1)
            let distance2 = userLoc.distance(from: loc2)

            return distance1 < distance2
        }
    }
}

