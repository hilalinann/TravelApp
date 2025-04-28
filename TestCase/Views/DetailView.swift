import SwiftUI

struct DetailView: View {
    let location: CityLocation
    @ObservedObject var viewModel: LocationViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showMap = false
    @State private var isImageLoaded = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Theme.textColor)
                            .font(.system(size: 22))
                    }
                    
                    Spacer()
                    
                    Text(location.name)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Theme.textColor)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer()
                    
                    Button {
                        viewModel.toggleFavorite(location: location)
                    } label: {
                        Image(systemName: viewModel.isFavorite(locationId: location.id) ? "heart.fill" : "heart")
                            .foregroundColor(Theme.favoriteColor)
                            .font(.system(size: 22))
                    }
                }
                .padding()
                .background(Theme.navigationBarBackgroundColor)
                .shadow(color: Theme.shadowColor, radius: 3, y: 1)
                
                ScrollView {
                    VStack(spacing: 0) {
                        if let imageUrl = location.image {
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .onAppear {
                                        isImageLoaded = true
                                    }
                            } placeholder: {
                                Rectangle()
                                    .fill(Theme.secondaryBackgroundColor)
                                    .frame(height: 200)
                            }
                            .padding(.top, 120)
                        }
                        
                        Text(location.description)
                            .font(.system(size: 16))
                            .foregroundColor(Theme.textColor)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 80)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Theme.backgroundColor)
            
            VStack {
                Button {
                    showMap = true
                } label: {
                    Text("Haritada Göster")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accentColor)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
            .background(
                Rectangle()
                    .fill(Theme.backgroundColor)
                    .shadow(color: Theme.shadowColor, radius: 5, y: -5)
            )
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showMap) {
            LocationMapView(location: location)
        }
        .onAppear {
            if location.image == nil {
            }
        }
    }
}

