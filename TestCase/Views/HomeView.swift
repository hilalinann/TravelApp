import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: LocationViewModel
    @State private var showingFavorites = false
    @State private var expandedCityId: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom navigation bar
                HStack {
                    Text("Önemli Konumlar")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Spacer()
                    
                    Button {
                        showingFavorites = true
                    } label: {
                        Image(systemName: "heart")
                            .foregroundColor(.red)
                            .font(.system(size: 22))
                    }
                }
                .padding()
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 3, y: 1)
                
                // City list
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.cities) { city in
                            CityRow(city: city, viewModel: viewModel)
                                .onAppear {
                                    viewModel.loadMoreIfNeeded(currentCity: city)
                                }
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showingFavorites) {
                // Navigate to the FavoritesView
                FavoritesView() // Here is your favorites page
            }
        }
    }
}

struct CityRow: View {
    let city: City
    @ObservedObject var viewModel: LocationViewModel
    @State private var expandedCityId: String?
    
    var body: some View {
        VStack(spacing: 8) {
            // City header button
            Button {
                if !city.locations.isEmpty {
                    withAnimation {
                        if expandedCityId == city.id {
                            expandedCityId = nil
                        } else {
                            expandedCityId = city.id
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: expandedCityId == city.id ? "minus" : "plus")
                        .foregroundColor(.gray)
                        .frame(width: 20)
                    
                    Text(city.name)
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .medium))
                    
                    Spacer()
                    
                    NavigationLink(destination: CityMapView(city: city)) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            
            // Locations
            if expandedCityId == city.id {
                VStack(spacing: 8) {
                    ForEach(city.locations) { location in
                        LocationRow(location: location, viewModel: viewModel)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
}

struct LocationRow: View {
    let location: CityLocation
    @ObservedObject var viewModel: LocationViewModel
    @State private var showingDetail = false
    
    var body: some View {
        HStack {
            Button {
                showingDetail = true
            } label: {
                HStack {
                    Text(location.name)
                        .foregroundColor(.primary)
                        .font(.system(size: 14))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 1)
            }
            
            Button {
                viewModel.toggleFavorite(location: location)
            } label: {
                Image(systemName: viewModel.isFavorite(locationId: location.id) ? "heart.fill" : "heart")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }
            .padding(.leading, 8)
        }
        .navigationDestination(isPresented: $showingDetail) {
            DetailView(location: location, viewModel: viewModel)
        }
    }
}

#Preview {
    HomeView(viewModel: LocationViewModel())
}

