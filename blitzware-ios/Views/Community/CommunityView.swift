//
//  CommunityView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 13/11/2023.
//

import SwiftUI

struct ChatMsg: View {
    var username: String
    var message: String
    var date: Date
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(username)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                Spacer()
                Text("\(formattedDate(date))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Text(message)
                .padding(10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .contextMenu {
            Button(action: onDelete) {
                Text("Delete")
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        return formatter.string(from: date)
    }
}

struct ChatList: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var msg: String = ""
    @State private var showAlert = false

    var body: some View {
        VStack {
            if viewModel.requestState == .error {
                Text(viewModel.errorData?.message ?? "Unknown error")
                    .foregroundColor(.red)
            }
            if viewModel.requestState == .pending || viewModel.requestState == .sent {
                ProgressView()
            }
            else {
                ScrollView {
                    ForEach(viewModel.generalChatMsgs, id: \.id) { chatMsg in
                        ChatMsg(username: chatMsg.username, message: chatMsg.message, date: chatMsg.date, onDelete: {
                            deleteChatMessage(chatMsg.id)
                        })
                    }
                }
                HStack {
                    TextField("Type here, \(viewModel.accountData!.account.username)...", text: $msg)
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.title)
                            .foregroundColor(msg.isEmpty ? .gray : .blue)
                            .padding(10)
                    }
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .disabled(msg.isEmpty)
                }
                .padding()
            }
        }
        .onAppear(perform: {
            Task {
                await viewModel.getChatMsgsByChatId(id: 1)
            }
        })
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Oops!"),
                message: Text("Please provide a valid message!"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func deleteChatMessage(_ id: Int) {
        Task {
            await viewModel.deleteChatMsgById(id: id)
        }
    }
    
    func sendMessage() {
        if msg.isEmpty {
            showAlert = true
        }
        else {
            Task {
                await viewModel.createChatMsg(msg: msg, chatId: 1)
                msg = ""
            }
        }
    }
}

struct CommunityView: View {
    var body: some View {
        NavigationView {
            ChatList()
                .navigationBarTitle("Community")
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Use compact navigation style
    }
}
