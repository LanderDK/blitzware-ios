//
//  AccountLogsView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 14/11/2023.
//

import SwiftUI

struct LogView: View {
    var date: Date
    var action: String
    var message: String
    var onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(action): \(message)")
                    .font(.headline)
                Text(formattedDate(date))
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
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        return formatter.string(from: date)
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
                    LogView(date: log.date, action: log.action, message: log.message, onDelete: {
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
