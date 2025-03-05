import Foundation

struct WalletList: Identifiable, Codable {
    let id: String // list name
    var wallets: Set<String> // Set of wallet addresses
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String, wallets: Set<String> = [], createdAt: Date = Date()) {
        self.id = id
        self.wallets = wallets
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }
} 