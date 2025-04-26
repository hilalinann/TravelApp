import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "https://storage.googleapis.com/invio-com/usg-challenge/city-location/page"
    
    private init() {}
    
    func fetchLocations(page: Int) async throws -> CityLocationResponse {
        let urlString = "\(baseURL)-\(page).json"
        print("📡 Fetching from URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            throw URLError(.badURL)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw URLError(.badServerResponse)
            }
            
            print("📥 Response status code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📦 Raw response: \(responseString)")
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CityLocationResponse.self, from: data)
                print("✅ Successfully decoded response with \(response.data.count) cities")
                return response
            } else {
                print("❌ Server error: \(httpResponse.statusCode)")
                throw URLError(.badServerResponse)
            }
        } catch {
            print("❌ Network or decoding error: \(error)")
            throw error
        }
    }
}

