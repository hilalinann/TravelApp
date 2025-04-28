import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: LocationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
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
            
            if viewModel.getFavoriteLocations().isEmpty {
                Text("Henüz hiçbir konumu favorilere eklemedin.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.secondaryTextColor)
                    .padding()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
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
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)           
        .background(Theme.backgroundColor)
    }
}

