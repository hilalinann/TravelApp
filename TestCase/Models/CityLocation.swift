import Foundation

struct CityLocationResponse: Codable {
    let currentPage: Int
    let totalPages: Int
    let total: Int
    let itemPerPage: Int
    let pageSize: Int
    let data: [City]

    enum CodingKeys: String, CodingKey {
        case currentPage
        case totalPages = "totalPage" 
        case total
        case itemPerPage
        case pageSize
        case data
    }
}

struct City: Identifiable, Codable, Equatable {
    var id: String { name }
    let name: String
    let locations: [CityLocation]

    enum CodingKeys: String, CodingKey {
        case name = "city"
        case locations
    }
    
    static func == (lhs: City, rhs: City) -> Bool {
        lhs.name == rhs.name
    }
}

struct CityLocation: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let description: String
    let coordinates: Coordinates
    let image: String?
    
    static func == (lhs: CityLocation, rhs: CityLocation) -> Bool {
        lhs.id == rhs.id
    }
}

struct Coordinates: Codable, Equatable {
    let lat: Double
    let lng: Double
}

