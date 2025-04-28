import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "https://storage.googleapis.com/invio-com/usg-challenge/city-location/page"
    
    private init() {}
    
    func fetchLocations(page: Int) async throws -> CityLocationResponse {
        let urlString = "\(baseURL)-\(page).json"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CityLocationResponse.self, from: data)
                return response
            } else {
                throw URLError(.badServerResponse)
            }
        } catch {
            throw error
        }
    }
}

