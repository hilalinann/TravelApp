import Foundation

class FavoritesManager {
    private let favoritesKey = "favoriteLocations" // UserDefaults anahtarı
    
    // Favori konumları al
    func getFavoriteLocations() -> [String] {
        let defaults = UserDefaults.standard
        return defaults.array(forKey: favoritesKey) as? [String] ?? []
    }
    
    // Konumu favorilere ekle
    func addFavorite(locationId: String) {
        var favorites = getFavoriteLocations()
        if !favorites.contains(locationId) {
            favorites.append(locationId)
            saveFavorites(favorites)
        }
    }
    
    // Konumu favorilerden çıkar
    func removeFavorite(locationId: String) {
        var favorites = getFavoriteLocations()
        if let index = favorites.firstIndex(of: locationId) {
            favorites.remove(at: index)
            saveFavorites(favorites)
        }
    }
    
    // Favorileri kaydet
    private func saveFavorites(_ favorites: [String]) {
        let defaults = UserDefaults.standard
        defaults.set(favorites, forKey: favoritesKey)
    }
    
    // Konumun favori olup olmadığını kontrol et
    func isFavorite(locationId: String) -> Bool {
        return getFavoriteLocations().contains(locationId)
    }
}

