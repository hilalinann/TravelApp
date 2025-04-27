import Foundation
import SwiftUI

@MainActor
class LocationViewModel: ObservableObject {
    @Published var cities: [City] = []
    @Published var expandedCities: Set<String> = []
    @Published var favoriteLocations: [CityLocation] = []
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var isLoading = false
    @Published var error: Error?
    @Published var favoriteLocationIds: Set<Int> = []
    private let favoritesKey = "favoriteLocations"
    
    // Örnek konumlar - gerçek uygulamada bu veriler API'den gelecektir
    private let allLocations: [CityLocation] = [
        CityLocation(id: 1, name: "Anıtkabir", description: "Türkiye Cumhuriyeti'nin kurucusu Atatürk'ün anıt mezarı.", coordinates: Coordinates(lat: 39.925018, lng: 32.836956), image: nil),
        CityLocation(id: 2, name: "Topkapı Sarayı", description: "Osmanlı İmparatorluğu'nun yönetim merkezi.", coordinates: Coordinates(lat: 41.0116, lng: 28.9833), image: nil),
        CityLocation(id: 3, name: "Ayasofya", description: "Bizans döneminden kalma tarihi kilise.", coordinates: Coordinates(lat: 41.0086, lng: 28.9802), image: nil)
    ]
    
    init() {
        loadFavorites()
        Task {
            await fetchLocations()
        }
    }
    
    func getAllLocations() -> [CityLocation] {
        return allLocations
    }
    
    func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([Int].self, from: data) {
            favoriteLocationIds = Set(decoded)
        }
    }
    
    func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(Array(favoriteLocationIds)) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    func fetchLocations() async {
        guard !isLoading else {
            print("🔄 LocationViewModel: Zaten yükleme yapılıyor, yeni istek atlanıyor")
            return
        }
        print("🔵 LocationViewModel: fetchLocations başlatılıyor - Sayfa: \(currentPage)")
        
        isLoading = true
        error = nil
        
        do {
            print("🔵 LocationViewModel: API çağrısı yapılıyor")
            let response = try await APIService.shared.fetchLocations(page: currentPage)
            print("✅ LocationViewModel: API yanıtı alındı - \(response.data.count) şehir")
            
            if currentPage == 1 {
                print("🔵 LocationViewModel: İlk sayfa, şehirler sıfırlanıyor")
                cities = response.data
            } else {
                print("🔵 LocationViewModel: Mevcut şehirlere ekleme yapılıyor")
                cities.append(contentsOf: response.data)
            }
            
            print("📊 LocationViewModel: Toplam şehir sayısı: \(cities.count)")
            print("📊 LocationViewModel: Mevcut sayfa: \(response.currentPage), Toplam sayfa: \(response.totalPages)")
            
            currentPage = response.currentPage
            totalPages = response.totalPages
            error = nil
        } catch {
            print("❌ LocationViewModel: Hata oluştu - \(error.localizedDescription)")
            self.error = error
        }
        
        isLoading = false
        print("🔵 LocationViewModel: fetchLocations tamamlandı")
    }
    
    func loadMoreIfNeeded(currentCity: City) {
        guard let lastCity = cities.last,
              lastCity.id == currentCity.id,
              currentPage < totalPages,
              !isLoading else { return }
        
        currentPage += 1
        Task {
            await fetchLocations()
        }
    }
    
    func toggleCityExpansion(_ cityId: String) {
        if expandedCities.contains(cityId) {
            expandedCities.remove(cityId)
        } else {
            expandedCities.insert(cityId)
        }
    }
    
    func collapseAllCities() {
        expandedCities.removeAll()
    }
    
    func toggleFavorite(location: CityLocation) {
        if isFavorite(locationId: location.id) {
            favoriteLocationIds.remove(location.id)
        } else {
            favoriteLocationIds.insert(location.id)
        }
        saveFavorites()
    }
    
    func isFavorite(locationId: Int) -> Bool {
        return favoriteLocationIds.contains(locationId)
    }
}