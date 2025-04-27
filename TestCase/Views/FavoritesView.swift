import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: LocationViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var locations: [CityLocation] = []
    
    var body: some View {
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
                
                Text("Favorilerim")
                    .font(.system(size: 20, weight: .semibold))
                
                Spacer()
                
                // Empty space for balance
                Button(action: {}) {
                    Image(systemName: "")
                        .frame(width: 22)
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 3, y: 1)
            
            List {
                ForEach(locations) { location in
                    NavigationLink(destination: DetailView(location: location, viewModel: viewModel)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(location.name)
                                    .font(.headline)
                                Text(location.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button {
                                viewModel.toggleFavorite(location: location)
                                loadFavorites()
                            } label: {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadFavorites()
        }
    }
    
    private func loadFavorites() {
        locations = viewModel.getAllLocations().filter { viewModel.isFavorite(locationId: $0.id) }
    }
}

#Preview {
    NavigationStack {
        FavoritesView(viewModel: LocationViewModel())
    }
}

