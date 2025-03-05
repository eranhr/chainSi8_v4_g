import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        NavigationView {
            HSplitView {
                LeftPaneView(viewModel: viewModel)
                    .frame(minWidth: 250, maxWidth: .infinity)
                
                RightPaneView(viewModel: viewModel)
                    .frame(maxWidth: .infinity)
            }
            .toolbar {
                ToolbarItem {
                    Button("Test Redis") {
                        Task {
                            if let result = try? await RedisService.shared.testConnection() {
                                print("Redis test result: \(result)")
                            }
                        }
                    }
                }
            }
        }
    }
} 