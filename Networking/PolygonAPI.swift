import Foundation
import Combine

class PolygonAPI {
    static let shared = PolygonAPI()
    private let apiKey = "YOUR_POLYGON_API_KEY" // <--- Replace this
    
    private init() {}
    
    func fetchOptionIV(ticker: String, expiration: String) -> AnyPublisher<[OptionIVPoint], Error> {
        let urlStr = "https://api.polygon.io/v3/reference/options/contracts?underlying_ticker=\(ticker)&expiration_date=\(expiration)&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlStr) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, _ in
                try self.parseOptionIVResponse(data)
            }
            .eraseToAnyPublisher()
    }
    
    private func parseOptionIVResponse(_ data: Data) throws -> [OptionIVPoint] {
        struct Response: Decodable {
            struct Result: Decodable {
                let strike_price: Double
                let expiration_date: String
                let implied_volatility: Double?
            }
            let results: [Result]
        }
        
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        
        return decoded.results.compactMap {
            guard let iv = $0.implied_volatility else { return nil }
            return OptionIVPoint(strike: $0.strike_price,
                                 expiration: $0.expiration_date,
                                 iv: iv)
        }
    }
}
