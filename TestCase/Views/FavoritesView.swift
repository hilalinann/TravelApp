import SwiftUI

struct FavoritesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom navigation bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 22))
                    }
                    
                    Spacer()
                    
                    Text("Favorilerim")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Spacer()
                    
                    // Empty space for balance (keeps the layout balanced)
                    Button(action: {}) {
                        Image(systemName: "")
                            .frame(width: 22)
                    }
                }
                .padding()
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 3, y: 1)
                
                // Content of Favorites
                VStack {
                    Text("Favorileriniz burada görünecek.")
                        .font(.title2)
                        .padding()
                    
                    // Add more content as needed
                }
                .padding()
                
                Spacer() // Keeps the content at the bottom
            }
            .navigationBarBackButtonHidden(true) // Hide default back button
            .navigationBarHidden(true)           // Hide default navigation bar
        }
    }
}

#Preview {
    FavoritesView()
}

