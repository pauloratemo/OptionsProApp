import Foundation

struct OptionIVPoint: Identifiable {
    let id = UUID()
    let strike: Double
    let expiration: String
    let iv: Double
}
