import SwiftUI
import Charts

struct MiddlePaneView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var isShowingAddToListMenu = false
    @State private var newNote = ""
    
    var body: some View {
        if let wallet = viewModel.selectedWallet {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Image(systemName: "bitcoinsign.circle.fill") // TODO: Dynamic coin type
                            .font(.title)
                        Text(wallet.displayAddress)
                            .font(.title2)
                        Spacer()
                        Button("Submit Report") {
                            // TODO: Implement report submission
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Menu {
                            ForEach(viewModel.openLists) { list in
                                Button(list.id) {
                                    Task {
                                        try? await viewModel.addWalletToList(wallet.id, listName: list.id)
                                    }
                                }
                            }
                            
                            Divider()
                            
                            Button("New List...") {
                                isShowingAddToListMenu = true
                            }
                        } label: {
                            Text("Add to List")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.bottom)
                    
                    // Labels
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(wallet.labels), id: \.self) { label in
                                Text(label)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.secondary.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    // Lists
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(wallet.lists), id: \.self) { list in
                                Text(list)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    // Summary
                    GroupBox("Summary") {
                        Text("Wallet analysis summary will appear here...")
                            .padding()
                    }
                    
                    // Similar Wallets
                    GroupBox("Similar Wallets") {
                        VStack(alignment: .leading) {
                            ForEach(0..<5) { _ in // TODO: Replace with actual similar wallets
                                SimilarWalletRow()
                                Divider()
                            }
                        }
                        .padding()
                    }
                    
                    // Financial Information
                    GroupBox("Financial Information") {
                        VStack {
                            Chart {
                                ForEach(0..<10, id: \.self) { i in
                                    LineMark(
                                        x: .value("Day", "\(i)"),
                                        y: .value("Value", Double.random(in: 0...100))
                                    )
                                }
                            }
                            .frame(height: 200)
                            .padding()
                        }
                    }
                    
                    // Notes
                    GroupBox("Notes") {
                        VStack {
                            // TODO: Show existing notes
                            
                            HStack {
                                TextField("Add a note...", text: $newNote)
                                    .textFieldStyle(.roundedBorder)
                                
                                Button("Add") {
                                    // TODO: Add note
                                    newNote = ""
                                }
                                .disabled(newNote.isEmpty)
                            }
                        }
                        .padding()
                    }
                }
                .padding()
            }
        } else {
            Text("Select a wallet to view details")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct SimilarWalletRow: View {
    var body: some View {
        HStack {
            Text("95%")
                .foregroundColor(.green)
                .font(.callout)
                .monospaced()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Image(systemName: "bitcoinsign.circle.fill")
                .foregroundColor(.orange)
            
            Text("0x1234...5678")
                .lineLimit(1)
            
            Spacer()
            
            Text("Exchange")
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
} 