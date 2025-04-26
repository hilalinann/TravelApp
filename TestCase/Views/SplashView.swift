import SwiftUI

struct SplashView: View {
    @State private var isLoading = true
    @State private var showError = false
    @State private var navigateToHome = false
    @StateObject private var viewModel = LocationViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    Text("Şehirlerdeki\nÖnemli Konumlar")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    }
                }
            }
        }
        .task {
            do {
                isLoading = true
                await viewModel.fetchLocations()
                
                if viewModel.error != nil {
                    showError = true
                } else {
                    withAnimation {
                        navigateToHome = true
                    }
                }
            } catch {
                showError = true
            }
            isLoading = false
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            HomeView(viewModel: viewModel)
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tekrar Dene") {
                Task {
                    do {
                        isLoading = true
                        await viewModel.fetchLocations()
                        
                        if viewModel.error != nil {
                            showError = true
                        } else {
                            withAnimation {
                                navigateToHome = true
                            }
                        }
                        isLoading = false
                    } catch {
                        showError = true
                        isLoading = false
                    }
                }
            }
        } message: {
            Text("Veriler yüklenirken bir hata oluştu. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.")
        }
    }
}

#Preview {
    SplashView()
}

