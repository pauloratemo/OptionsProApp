import Foundation
import Combine

class PolygonWebSocketManager: NSObject, ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession = URLSession(configuration: .default)
    private let apiKey = "YOUR_POLYGON_API_KEY" // <--- Replace this
    
    @Published var liveIVPoints: [OptionIVPoint] = []
    @Published var isConnected = false
    @Published var errorMessage: String? = nil
    
    func connect(ticker: String) {
        let urlStr = "wss://socket.polygon.io/options"
        guard let url = URL(string: urlStr) else { return }
        
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        isConnected = true
        authenticate()
        listen()
    }
    
    func disconnect() {
        isConnected = false
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    private func authenticate() {
        let authMsg = ["action": "auth", "params": apiKey]
        send(json: authMsg)
    }
    
    func subscribe(to ticker: String) {
        let subMsg = ["action": "subscribe", "params": "O.\(ticker)"]
        send(json: subMsg)
    }
    
    private func send(json: [String: String]) {
        guard let webSocketTask = webSocketTask else { return }
        do {
            let data = try JSONSerialization.data(withJSONObject: json)
            let message = URLSessionWebSocketTask.Message.data(data)
            webSocketTask.send(message) { error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "WebSocket send error: \(error.localizedDescription)"
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "WebSocket JSON error: \(error.localizedDescription)"
            }
        }
    }
    
    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = "WebSocket receive error: \(error.localizedDescription)"
                    self.isConnected = false
                }
            case .success(let message):
                switch message {
                case .data(let data):
                    self.handleMessageData(data)
                case .string(let str):
                    if let data = str.data(using: .utf8) {
                        self.handleMessageData(data)
                    }
                @unknown default:
                    break
                }
                self.listen()
            }
        }
    }
    
    private func handleMessageData(_ data: Data) {
        // Parsing simplified for demo, adapt per Polygon docs
        struct PolygonOptionUpdate: Decodable {
            let ev: Double?         // implied volatility example field
            let strike_price: Double?
            let expiration_date: String?
        }
        
        do {
            let updates = try JSONDecoder().decode([PolygonOptionUpdate].self, from: data)
            var newPoints: [OptionIVPoint] = []
            for update in updates {
                if let iv = update.ev,
                   let strike = update.strike_price,
                   let expiration = update.expiration_date {
                    newPoints.append(OptionIVPoint(strike: strike, expiration: expiration, iv: iv))
                }
            }
            DispatchQueue.main.async {
                self.liveIVPoints = newPoints
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "WebSocket parse error: \(error.localizedDescription)"
            }
        }
    }
}
