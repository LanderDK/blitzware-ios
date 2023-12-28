//
//  AccountLogsView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 14/11/2023.
//

import SwiftUI

struct LogView: View {
    var action: String
    var message: String
    var date: String
    var onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(action): \(message)")
                    .font(.headline)
                Text(convertDateString(date) ?? "Error date")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        .cornerRadius(10)
        .shadow(color: Color.gray, radius: 5)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}

struct LogList: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        VStack {
            if viewModel.requestState == .error {
                Text(viewModel.errorData?.message ?? "Unknown error")
                    .foregroundColor(.red)
            }
            if viewModel.requestState == .pending || viewModel.requestState == .sent {
                ProgressView()
            }
            ScrollView {
                ForEach(viewModel.individualAccountLogs, id: \.id) { log in
                    LogView(action: log.action, message: log.message, date: log.date, onDelete: {
                        deleteLog(log.id)
                    })
                }
            }
        }
        .onAppear(perform: {
            Task {
                await viewModel.getLogsByUsername(username: viewModel.accountData!.account.username)
            }
        })
    }
    
    private func deleteLog(_ id: Int) {
        Task {
            await viewModel.deleteLogById(id: id)
        }
    }
}

struct AccountLogsView: View {
    var body: some View {
        LogList()
            .navigationTitle("Account Logs")
    }
}
