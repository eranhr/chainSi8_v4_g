import Foundation

struct Wallet: Codable, Identifiable, Hashable {
    let id: String // The wallet address
    var balance: Double
    var lastUpdated: Date
    var labels: Set<String>
    var similarWallets: Set<String>
    
    init(id: String, balance: Double = 0.0, labels: Set<String> = [], similarWallets: Set<String> = []) {
        self.id = id
        self.balance = balance
        self.lastUpdated = Date()
        self.labels = labels
        self.similarWallets = similarWallets
    }
} 