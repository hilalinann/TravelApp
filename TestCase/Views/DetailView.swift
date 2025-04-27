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
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .center) // Ortaya hizalama ekledim
                    
                    Spacer()
                    
                    Button {
                        // Favori ekle/çıkartma işlemi
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
                                    .scaledToFit()  // Görselin uygun şekilde sığmasını sağlıyor
                                    .frame(maxWidth: .infinity) // Görselin ekran genişliğine uymasını sağla
                                    .clipped()
                                    .onAppear {
                                        isImageLoaded = true
                                    }
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
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20) // Yalnızca yatay padding ekledim
                            .padding(.top, 20)
                            .padding(.bottom, 80)
                            .frame(maxWidth: .infinity, alignment: .leading) // Açıklama metnini sola hizaladım
                            .fixedSize(horizontal: false, vertical: true) // Yazının taşmaması için
                    }
                }
                .padding(.bottom, 20) // ScrollView altına padding ekle
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
        .onAppear {
            // Görsel veya içerik yüklemesi tamamlandığında yapılacak işlemler
            if location.image == nil {
                // Eğer resim yoksa, uygun bir placeholder veya varsayılan resim gösterilebilir.
            }
        }
    }
}

