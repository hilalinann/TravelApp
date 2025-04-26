import SwiftUI
import MapKit

struct CityMapView: View {
    let city: City
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    @State private var selectedLocation: CityLocation?
    @State private var showingDetail = false
    
    init(city: City) {
        self.city = city
        // Şehrin ilk lokasyonunun koordinatlarını kullanarak haritayı merkezle
        if let firstLocation = city.locations.first {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: firstLocation.coordinates.lat,
                    longitude: firstLocation.coordinates.lng
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        } else {
            // Varsayılan bir bölge (Türkiye merkezi)
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 39.9334, longitude: 32.8597),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Map
            Map(coordinateRegion: $region, annotationItems: city.locations) { location in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: location.coordinates.lat,
                    longitude: location.coordinates.lng
                )) {
                    if location.id == city.locations.first?.id {
                        // İlk konum için özel marker
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 44, height: 44)
                            )
                            .shadow(radius: 2)
                    } else if location.id == selectedLocation?.id {
                        // Seçili konum için özel marker
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.blue)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 48, height: 48)
                            )
                            .shadow(radius: 3)
                    } else {
                        // Diğer konumlar için yıldız
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
            }
            .edgesIgnoringSafeArea(.all)
            
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
                
                Text(city.name.uppercased())
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Bottom horizontal scrollable list
            VStack {
                Spacer()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(city.locations) { location in
                            LocationCard(location: location, selectedLocation: $selectedLocation)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 200)
                .background(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, y: -2)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showingDetail) {
            if let selectedLocation = selectedLocation {
                DetailView(location: selectedLocation, viewModel: LocationViewModel())
            }
        }
    }
}

struct LocationCard: View {
    let location: CityLocation
    @Binding var selectedLocation: CityLocation?
    @State private var showingDetail = false
    
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
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                NavigationLink(destination: DetailView(location: location, viewModel: LocationViewModel())) {
                    Text("Detaya Git")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .frame(width: 200)
            .padding(8)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 3)
        }
    }
} 