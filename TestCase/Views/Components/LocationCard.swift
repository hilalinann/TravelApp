import SwiftUI
import CoreLocation

struct LocationCard: View {
    let location: CityLocation
    @Binding var selectedLocation: CityLocation?
    let userLocation: UserLocation?

    private func calculateDistance() -> String {
        guard let userLocation = userLocation else {
            return ""
        }

        let userCoordinate = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let locationCoordinate = CLLocation(latitude: location.coordinates.lat, longitude: location.coordinates.lng)

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

