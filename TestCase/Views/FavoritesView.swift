import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: LocationViewModel
    @Environment(\.presentationMode) var presentationMode  // Bu, geri gitmeyi sağlar.
    
    var body: some View {
        VStack {
            // Custom navigation bar
            HStack {
                Button(action: {
                    // Geri gitmek için işlem yapılacak
                    presentationMode.wrappedValue.dismiss()  // Bu, favoriler sayfasından çıkıp anasayfaya dönecek
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Theme.textColor)
                        .font(.system(size: 22))
                }
                
                Spacer()
                
                Text("Favorilerim")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Theme.textColor)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "")
                        .frame(width: 22)
                }
            }
            .padding()
            .background(Theme.navigationBarBackgroundColor)
            .shadow(color: Theme.shadowColor, radius: 3, y: 1)
            
            // Favori konumları listele veya mesaj göster
            if viewModel.getFavoriteLocations().isEmpty {
                // Eğer favori konum yoksa, mesaj göster
                Text("Henüz hiçbir konumu favorilere eklemedin.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.secondaryTextColor)
                    .padding()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Favori konumları listele
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.getFavoriteLocations(), id: \.id) { location in
                            LocationRow(location: location, viewModel: viewModel)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarBackButtonHidden(true) // Varsayılan geri tuşunu gizle
        .navigationBarHidden(true)           // Başka navigation bar'ı gizle
        .background(Theme.backgroundColor)
    }
}

