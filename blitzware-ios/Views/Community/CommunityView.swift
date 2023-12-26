//
//  CommunityView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 13/11/2023.
//

import SwiftUI

struct ChatMsg: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.colorScheme) var colorScheme
    var username: String
    var message: String
    var date: String
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: username == viewModel.accountData?.account.username ? .trailing : .leading, spacing: 8) {
            HStack {
                if username != viewModel.accountData?.account.username {
                    Text(username)
                        .font(.subheadline)
                        .foregroundColor(username == viewModel.accountData?.account.username ? Color.blue : colorScheme == .dark ? Color.white : Color.black)
                }
                Spacer()
                Text(convertDateString(date) ?? "Error date")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Text(message)
                .padding(10)
                .background(username == viewModel.accountData?.account.username ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .fixedSize(horizontal: false, vertical: true)
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
            ReverseScrollView {
                VStack(spacing: 8) {
                    ForEach(viewModel.generalChatMsgs, id: \.id) { chatMsg in
                        ChatMsg(username: chatMsg.username, message: chatMsg.message, date: chatMsg.dateString, onDelete: {
                            deleteChatMessage(chatMsg.id)
                        })
                    }
                }
            }
            //.navigationBarTitle(Text("Conversation"))
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
                .navigationBarTitle("Community General Chat")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
