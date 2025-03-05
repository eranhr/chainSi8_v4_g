import Foundation
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    private let redisService: RedisServiceProtocol
    
    @Published var openLists: [WalletList] = []
    @Published var selectedList: WalletList?
    @Published var selectedWallet: Wallet?
    @Published var isAnalyzing: Set<String> = []
    @Published var chatMessages: [ChatMessage] = []
    
    init(redisService: RedisServiceProtocol = RedisService.shared) {
        self.redisService = redisService
        // Load any previously opened lists
        Task {
            // Test Redis connection first
            if let success = try? await redisService.testConnection() {
                print("Redis connection test: \(success ? "SUCCESS" : "FAILED")")
            }
            try? await loadSavedLists()
        }
    }
    
    private func loadSavedLists() async throws {
        if let redisService = redisService as? RedisService {
            let listNames = try await redisService.getAllLists()
            for name in listNames {
                if let list = try await redisService.getList(name) {
                    openLists.append(list)
                }
            }
        }
    }
    
    func createNewList(name: String) async throws {
        let newList = WalletList(id: name)
        try await redisService.saveList(newList)
        openLists.append(newList)
        selectedList = newList
    }
    
    func openList(name: String) async throws {
        if let existingList = openLists.first(where: { $0.id == name }) {
            selectedList = existingList
            return
        }
        
        guard let list = try await redisService.getList(name) else { return }
        openLists.append(list)
        selectedList = list
    }
    
    func addWalletToList(_ wallet: String, listName: String) async throws {
        guard var list = openLists.first(where: { $0.id == listName }) else { return }
        list.wallets.insert(wallet)
        list.updatedAt = Date()
        try await redisService.saveList(list)
        
        if let index = openLists.firstIndex(where: { $0.id == listName }) {
            openLists[index] = list
            if selectedList?.id == listName {
                selectedList = list
            }
        }
        
        // Start analyzing the wallet
        try await analyzeWallet(wallet)
    }
    
    func removeWallet(_ wallet: String, from listName: String) async throws {
        guard var list = openLists.first(where: { $0.id == listName }) else { return }
        list.wallets.remove(wallet)
        list.updatedAt = Date()
        try await redisService.saveList(list)
        
        if let index = openLists.firstIndex(where: { $0.id == listName }) {
            openLists[index] = list
            if selectedList?.id == listName {
                selectedList = list
            }
        }
        
        if selectedWallet?.id == wallet {
            selectedWallet = nil
        }
    }
    
    func selectWallet(_ address: String) async throws {
        isAnalyzing.insert(address)
        defer { isAnalyzing.remove(address) }
        
        if let wallet = try await redisService.getWallet(address) {
            selectedWallet = wallet
        } else {
            // Create a new wallet if it doesn't exist
            let newWallet = Wallet(
                id: address,
                status: .analyzing,
                lastAnalyzed: Date(),
                coinType: .ethereum, // TODO: Detect coin type
                labels: [],
                lists: []
            )
            try await redisService.saveWallet(newWallet)
            selectedWallet = newWallet
            try await analyzeWallet(address)
        }
    }
    
    func analyzeWallet(_ address: String) async throws {
        isAnalyzing.insert(address)
        defer { isAnalyzing.remove(address) }
        
        // TODO: Implement actual wallet analysis
        // This should:
        // 1. Detect coin type
        // 2. Get transaction history
        // 3. Analyze patterns
        // 4. Update labels
        // 5. Find similar wallets
    }
    
    func exportListAsCSV(_ list: WalletList) -> String {
        return list.wallets.joined(separator: "\n")
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
} 
