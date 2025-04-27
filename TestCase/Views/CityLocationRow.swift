import SwiftUI

struct CityLocationRow: View {
    let location: CityLocation
    @ObservedObject var viewModel: LocationViewModel
    
    var body: some View {
        HStack {
            Text(location.name)
                .foregroundColor(.primary)
                .font(.system(size: 14))
            Spacer()
            Button {
                viewModel.toggleFavorite(location: location)
            } label: {
                Image(systemName: viewModel.isFavorite(locationId: location.id) ? "heart.fill" : "heart")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 1)
    }
}

