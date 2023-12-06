//
//  AppLogsView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 06/12/2023.
//

import SwiftUI

struct AppLogsList: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isShowingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    var application: ApplicationData
    
    var body: some View {
        VStack {
            Text("Application Logs - \(application.name)")
                .font(.title)
                .padding()
            VStack {
                if viewModel.requestState == .error {
                    Text(viewModel.errorData?.message ?? "Unknown error")
                        .foregroundColor(.red)
                }
                if viewModel.requestState == .pending || viewModel.requestState == .sent {
                    ProgressView()
                }
                List(viewModel.appLogs, id: \.id) { appLog in
                    AppLogRowView(appLog: appLog)
                        .contextMenu {
                            CustomButton(title: "Delete") {
                                Task {
                                    await viewModel.deleteAppLogById(appLogId: appLog.id)
                                    if viewModel.requestState == .success {
                                        alertTitle = "Success!"
                                        alertMessage = "App Log deleted successfully."
                                        isShowingAlert = true
                                    } else {
                                        alertTitle = "Oops!"
                                        alertMessage = viewModel.errorData?.message ?? "Unkown error"
                                        isShowingAlert = true
                                    }
                                }
                            }
                        }
                }
            }.onAppear(perform: {
                Task {
                    await viewModel.getAppLogsOfApplication(applicationId: application.id)
                }
            })
            .alert(isPresented: $isShowingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct AppLogRowView: View {
    @EnvironmentObject var viewModel: AppViewModel
    var appLog: AppLogData

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(appLog.username)
                .foregroundColor(.primary)
                .font(.headline)
            HStack {
                Text("Date: ")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(appLog.dateString)
                    .font(.subheadline)
            }
            HStack {
                Text("Action: ")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(appLog.action)
                    .font(.subheadline)
            }
            HStack {
                Text("IP: ")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(appLog.ip)
                    .font(.subheadline)
            }
        }
    }
}

