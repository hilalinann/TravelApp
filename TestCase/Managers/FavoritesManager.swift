import Foundation

class FavoritesManager {
    private let favoritesKey = "favoriteLocations"
    
    func getFavoriteLocations() -> [String] {
        let defaults = UserDefaults.standard
        return defaults.array(forKey: favoritesKey) as? [String] ?? []
    }
    
    func addFavorite(locationId: String) {
        var favorites = getFavoriteLocations()
        if !favorites.contains(locationId) {
            favorites.append(locationId)
            saveFavorites(favorites)
        }
    }
    
    func removeFavorite(locationId: String) {
        var favorites = getFavoriteLocations()
        if let index = favorites.firstIndex(of: locationId) {
            favorites.remove(at: index)
            saveFavorites(favorites)
        }
    }
    
    private func saveFavorites(_ favorites: [String]) {
        let defaults = UserDefaults.standard
        defaults.set(favorites, forKey: favoritesKey)
    }
    
    func isFavorite(locationId: String) -> Bool {
        return getFavoriteLocations().contains(locationId)
    }
}

