import SwiftUI
import MapKit

struct CityMapView: View {
    let city: City
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    
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
                
                Text("ŞEHİR HARİTA SAYFASI")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Map
            Map(coordinateRegion: $region, annotationItems: city.locations) { location in
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
        }
        .navigationBarHidden(true)
    }
} 