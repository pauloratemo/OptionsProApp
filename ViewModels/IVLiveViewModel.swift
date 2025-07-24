import Foundation
import Combine

class IVLiveViewModel: ObservableObject {
    @Published var ivPointsByExpiration: [String: [OptionIVPoint]] = [:]
    @Published var errorMessage: String? = nil
    @Published var isOffline: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let polygonAPI = PolygonAPI.shared
    private let webSocketManager = PolygonWebSocketManager()
    
    private let ticker: String
    
    init(ticker: String) {
        self.ticker = ticker
        
        webSocketManager.$liveIVPoints
            .receive(on: DispatchQueue.main)
            .sink { [weak self] points in
                self?.groupPointsByExpiration(points: points)
            }
            .store(in: &cancellables)
        
        webSocketManager.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMsg in
                self?.errorMessage = errorMsg
                self?.isOffline = errorMsg != nil
            }
            .store(in: &cancellables)
        
        connectAndFetchInitial()
    }
    
    func connectAndFetchInitial() {
        webSocketManager.connect(ticker: ticker)
        webSocketManager.subscribe(to: ticker)
    }
    
    private func groupPointsByExpiration(points: [OptionIVPoint]) {
        var grouped: [String: [OptionIVPoint]] = [:]
        for p in points {
            grouped[p.expiration, default: []].append(p)
        }
        ivPointsByExpiration = grouped
    }
    
    func disconnect() {
        webSocketManager.disconnect()
    }
}
