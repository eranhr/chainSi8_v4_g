import Foundation

enum CoinType: String, Codable {
    case ethereum
    case bitcoin
    // Add more coins as needed
}

enum WalletStatus: String, Codable {
    case analyzing
    case analyzed
    case error
}

struct Wallet: Identifiable, Codable {
    let id: String // wallet address
    var status: WalletStatus
    var lastAnalyzed: Date
    var coinType: CoinType
    var labels: Set<String>
    var lists: Set<String>
    
    // Computed property for display purposes
    var displayAddress: String {
        let prefix = String(id.prefix(6))
        let suffix = String(id.suffix(4))
        return "\(prefix)...\(suffix)"
    }
}

struct WalletSimilarity: Identifiable, Codable {
    let id: UUID
    let wallet: Wallet
    let similarityScore: Double
    let isSuspicious: Bool
    
    init(wallet: Wallet, similarityScore: Double, isSuspicious: Bool) {
        self.id = UUID()
        self.wallet = wallet
        self.similarityScore = similarityScore
        self.isSuspicious = isSuspicious
    }
} 