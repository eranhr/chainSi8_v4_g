import SwiftUI

struct RightPaneView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            // Chat messages
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.chatMessages) { message in
                        ChatMessageView(message: message)
                    }
                }
                .padding()
            }
            
            // Message input
            HStack {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    guard !messageText.isEmpty else { return }
                    // TODO: Send message
                    messageText = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
    }
}

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.content)
                .padding()
                .background(message.isUser ? Color.blue : Color.secondary.opacity(0.2))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(12)
                .contextMenu {
                    Button {
                        // TODO: Copy message
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
} 