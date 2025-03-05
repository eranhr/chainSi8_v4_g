import SwiftUI
import UniformTypeIdentifiers

struct LeftPaneView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var isShowingNewListSheet = false
    @State private var newListName = ""
    @State private var isShowingFileImporter = false
    @State private var newWalletAddress = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 12) {
                Menu {
                    Button("Open...") {
                        // TODO: Show file picker for list
                        isShowingFileImporter = true
                    }
                    
                    Divider()
                    
                    ForEach(viewModel.openLists) { list in
                        Button(list.id) {
                            Task {
                                try? await viewModel.openList(name: list.id)
                            }
                        }
                    }
                    
                    if !viewModel.openLists.isEmpty {
                        Divider()
                    }
                    
                    Button("New List...") {
                        isShowingNewListSheet = true
                    }
                } label: {
                    Label("Add to List", systemImage: "plus.circle.fill")
                        .foregroundColor(.white)
                }
                .menuStyle(.borderlessButton)
                
                Button {
                    if let selectedList = viewModel.selectedList {
                        let csv = viewModel.exportListAsCSV(selectedList)
                        // TODO: Implement save dialog
                    }
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
                
                Button {
                    isShowingFileImporter = true
                } label: {
                    Label("Import", systemImage: "square.and.arrow.down")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color(.darkGray))
            
            // Lists tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.openLists) { list in
                        TabButton(
                            title: list.id,
                            isSelected: viewModel.selectedList?.id == list.id
                        ) {
                            Task {
                                try? await viewModel.openList(name: list.id)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 40)
            .background(Color(.separatorColor))
            
            // Wallet input
            HStack {
                TextField("Enter wallet address", text: $newWalletAddress)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        addWallet()
                    }
                
                Button(action: addWallet) {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(newWalletAddress.isEmpty || viewModel.selectedList == nil)
            }
            .padding()
            
            // Wallets list
            if let selectedList = viewModel.selectedList {
                List(Array(selectedList.wallets), id: \.self) { address in
                    WalletRow(
                        address: address,
                        isAnalyzing: viewModel.isAnalyzing.contains(address),
                        onRefresh: {
                            Task {
                                try? await viewModel.analyzeWallet(address)
                            }
                        },
                        onRemove: {
                            Task {
                                try? await viewModel.removeWallet(address, from: selectedList.id)
                            }
                        }
                    )
                    .onTapGesture {
                        Task {
                            try? await viewModel.selectWallet(address)
                        }
                    }
                }
                .onDrop(of: [UTType.plainText], isTargeted: nil) { providers in
                    Task {
                        for provider in providers {
                            if let item = try? await provider.loadItem(forTypeIdentifier: UTType.plainText.identifier),
                               let data = item as? Data,
                               let text = String(data: data, encoding: .utf8) {
                                let wallets = text.components(separatedBy: CharacterSet.newlines)
                                    .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
                                    .filter { !$0.isEmpty }
                                
                                for wallet in wallets {
                                    try? await viewModel.addWalletToList(wallet, listName: selectedList.id)
                                }
                            }
                        }
                    }
                    return true
                }
            } else {
                Text("No list selected")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $isShowingNewListSheet) {
            NewListSheet(isPresented: $isShowingNewListSheet, viewModel: viewModel)
        }
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: [UTType.plainText, UTType.commaSeparatedText]
        ) { result in
            Task {
                do {
                    let url = try result.get()
                    let data = try String(contentsOf: url)
                    let wallets = data.components(separatedBy: CharacterSet.newlines)
                        .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    
                    if let selectedList = viewModel.selectedList {
                        for wallet in wallets {
                            try? await viewModel.addWalletToList(wallet, listName: selectedList.id)
                        }
                    }
                } catch {
                    print("Error importing file: \(error)")
                }
            }
        }
    }
    
    private func addWallet() {
        guard !newWalletAddress.isEmpty,
              let selectedList = viewModel.selectedList else { return }
        
        Task {
            try? await viewModel.addWalletToList(newWalletAddress, listName: selectedList.id)
            newWalletAddress = ""
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.clear)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

struct WalletRow: View {
    let address: String
    let isAnalyzing: Bool
    let onRefresh: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            if isAnalyzing {
                ProgressView()
                    .controlSize(.small)
                    .help("Analyzing")
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .help("Analyzed")
            }
            
            Image(systemName: "bitcoinsign.circle.fill") // TODO: Dynamic coin type
                .foregroundColor(.orange)
                .help("Bitcoin")
            
            Text(address)
                .lineLimit(1)
                .truncationMode(.middle)
            
            Spacer()
            
            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .help("Refresh analysis")
            }
            .buttonStyle(.plain)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .help("Remove from list")
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

struct NewListSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: MainViewModel
    @State private var listName = ""
    
    var body: some View {
        VStack {
            Text("Create New List")
                .font(.headline)
            
            TextField("List name", text: $listName)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                
                Button("Create") {
                    guard !listName.isEmpty else { return }
                    Task {
                        try? await viewModel.createNewList(name: listName)
                        isPresented = false
                    }
                }
                .keyboardShortcut(.return, modifiers: [])
                .disabled(listName.isEmpty)
            }
            .padding()
        }
        .frame(width: 300)
        .padding()
    }
} 