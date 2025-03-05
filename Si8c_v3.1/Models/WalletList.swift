import Foundation

struct WalletList: Codable, Identifiable {
    let id: String // The list name
    var wallets: Set<String>
    var createdAt: Date
    var lastUpdated: Date
    
    init(id: String, wallets: Set<String> = []) {
        self.id = id
        self.wallets = wallets
        self.createdAt = Date()
        self.lastUpdated = Date()
    }
    
    mutating func addWallet(_ address: String) {
        wallets.insert(address)
        lastUpdated = Date()
    }
    
    mutating func removeWallet(_ address: String) {
        wallets.remove(address)
        lastUpdated = Date()
    }
} 