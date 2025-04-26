import SwiftUI

struct DetailView: View {
    let location: CityLocation
    @ObservedObject var viewModel: LocationViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showMap = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Custom navigation bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 22))
                    }
                    
                    Spacer()
                    
                    Text(location.name)
                        .font(.system(size: 20, weight: .semibold))
                    
                    Spacer()
                    
                    Button {
                        viewModel.toggleFavorite(location: location)
                    } label: {
                        Image(systemName: viewModel.isFavorite(locationId: location.id) ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                            .font(.system(size: 22))
                    }
                }
                .padding()
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 3, y: 1)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Location image
                        if let imageUrl = location.image {
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .clipped()
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 200)
                            }
                            .padding(.top, 120)
                        }
                        
                        // Description
                        Text(location.description)
                            .font(.system(size: 16))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 80)
                    }
                }
            }
            
            // Map button - Fixed at bottom
           VStack {
                Button {
                    showMap = true
                } label: {
                    Text("Haritada Göster")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
            .background(
                Rectangle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 5, y: -5)
            )
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showMap) {
            LocationMapView(location: location)
        }
    }
}

#Preview {
    NavigationStack {
        DetailView(
            location: CityLocation(
                id: 1,
                name: "Anıtkabir",
                description: "Türkiye Cumhuriyeti'nin kurucusu Atatürk'ün anıt mezarı.",
                coordinates: Coordinates(lat: 39.925018, lng: 32.836956),
                image: nil
            ),
            viewModel: LocationViewModel()
        )
    }
} 