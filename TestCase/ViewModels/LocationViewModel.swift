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
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let response = try await APIService.shared.fetchLocations(page: currentPage)
            
            if currentPage == 1 {
                cities = response.data
            } else {
                cities.append(contentsOf: response.data)
            }
            
            currentPage = response.currentPage
            totalPages = response.totalPages
            error = nil
        } catch {
            self.error = error
        }
        
        isLoading = false
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
    
    func getFavoriteLocations() -> [CityLocation] {
        return cities.flatMap { city in
            city.locations.filter { location in
                isFavorite(locationId: location.id)
            }
        }
    }
}

