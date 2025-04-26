import Foundation
import SwiftUI

@MainActor
class LocationViewModel: ObservableObject {
    @Published var cities: [City] = []
    @Published var expandedCities: Set<String> = []
    @Published var favoriteLocations: Set<Int> = []
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var isLoading = false
    @Published var error: Error?
    
    func fetchLocations() async {
        guard !isLoading else { return }
        
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
            print("Error in ViewModel: \(error)")
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
        if favoriteLocations.contains(location.id) {
            favoriteLocations.remove(location.id)
        } else {
            favoriteLocations.insert(location.id)
        }
    }
    
    func isFavorite(locationId: Int) -> Bool {
        favoriteLocations.contains(locationId)
    }
}