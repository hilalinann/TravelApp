import SwiftUI
import MapKit
import CoreLocation

struct CityMapView: View {
    let city: City
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    @State private var selectedLocation: CityLocation?
    @State private var showingDetail = false
    @State private var locationManager = LocationManager()
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
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: city.locations) { location in
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

                Text(city.name.uppercased())
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(uiColor: .label))

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .background(Color(uiColor: .systemBackground).opacity(0.8))

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
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(city.locations) { location in
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
}

struct LocationCard: View {
    let location: CityLocation
    @Binding var selectedLocation: CityLocation?
    let userLocation: UserLocation?
    
    private func calculateDistance() -> String {
        guard let userLocation = userLocation else {
            return ""
        }
        
        let userCoordinate = CLLocation(
            latitude: userLocation.coordinate.latitude,
            longitude: userLocation.coordinate.longitude
        )
        
        let locationCoordinate = CLLocation(
            latitude: location.coordinates.lat,
            longitude: location.coordinates.lng
        )
        
        let distance = userCoordinate.distance(from: locationCoordinate)
        
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }

    var body: some View {
        Button {
            selectedLocation = location
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                if let imageUrl = location.image {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 200, height: 120)
                    .clipped()
                    .cornerRadius(10)
                } else {
                    Color.gray.opacity(0.3)
                        .frame(width: 200, height: 120)
                        .cornerRadius(10)
                }

                Text(location.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textColor)
                    .lineLimit(1)

                HStack {
                    NavigationLink(destination: DetailView(location: location, viewModel: LocationViewModel())) {
                        Text("Detaya Git")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Theme.accentColor)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .background(Theme.accentColor.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    if let _ = userLocation {
                        Text(calculateDistance())
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Theme.secondaryTextColor)
                    }
                }
            }
            .frame(width: 200)
            .padding(8)
            .background(Theme.cardBackgroundColor)
            .cornerRadius(12)
            .shadow(color: Theme.shadowColor, radius: 3)
        }
    }
}


