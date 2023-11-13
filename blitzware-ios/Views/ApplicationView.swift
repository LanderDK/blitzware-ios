//
//  ApplicationView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 09/11/2023.
//

import SwiftUI

struct ApplicationsList: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isShowingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowingAddSheet = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Welcome back, \(viewModel.accountData!.account.username)!")
                    .font(.title)
                    .padding()
                Spacer()
                Button {
                    isShowingAddSheet = true
                } label: {
                    Image(systemName: "plus.app.fill")
                }
                .font(.title)
                .padding()
                .accentColor(Color(red: 25/255, green: 118/255, blue: 210/255))
            }
            VStack {
                if viewModel.requestState == .error {
                    Text(viewModel.errorData?.message ?? "Unkown error")
                        .foregroundColor(.red)
                }
                if viewModel.requestState == .pending || viewModel.requestState == .sent {
                    ProgressView()
                } else {
                    List(viewModel.applications, id: \.id) { application in
                        ApplicationRowView(application: application)
                            .contextMenu {
                                CustomButton(title: "Panel") {
                                    Task {
                                        await viewModel.login(username: "username", password: "password")
                                    }
                                }
                                if application.status == 1 {
                                    CustomButton(title: "Disable") {
                                        let newApp = ApplicationData(id: application.id, name: application.name, secret: application.secret, status: 0, hwidCheck: application.hwidCheck, developerMode: application.developerMode, integrityCheck: application.integrityCheck, freeMode: application.freeMode, twoFactorAuth: application.twoFactorAuth, programHash: application.programHash, version: application.version, downloadLink: application.downloadLink, adminRoleId: application.adminRoleId, adminRoleLevel: application.adminRoleLevel)
                                        Task {
                                            await viewModel.updateApplicationById(application: newApp)
                                        }
                                        if let index = viewModel.applications.firstIndex(where: { $0.id == application.id }) {
                                            viewModel.applications[index].status = 0
                                        }
                                    }
                                } else {
                                    CustomButton(title: "Enable") {
                                        let newApp = ApplicationData(id: application.id, name: application.name, secret: application.secret, status: 1, hwidCheck: application.hwidCheck, developerMode: application.developerMode, integrityCheck: application.integrityCheck, freeMode: application.freeMode, twoFactorAuth: application.twoFactorAuth, programHash: application.programHash, version: application.version, downloadLink: application.downloadLink, adminRoleId: application.adminRoleId, adminRoleLevel: application.adminRoleLevel)
                                        Task {
                                            await viewModel.updateApplicationById(application: newApp)
                                        }
                                        if let index = viewModel.applications.firstIndex(where: { $0.id == application.id }) {
                                            viewModel.applications[index].status = 1
                                        }
                                    }
                                }
                                CustomButton(title: "Delete") {
                                    Task {
                                        await viewModel.deleteApplicationById(applicationId: application.id)
                                        if viewModel.requestState == .success {
                                            alertTitle = "Success!"
                                            alertMessage = "Application was deleted successfully."
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
                }
            }.onAppear(perform: {
                Task {
                    await viewModel.getApplicationsOfAccount()
                }
            })
            .alert(isPresented: $isShowingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddApplicationView(isPresented: $isShowingAddSheet)
            }
        }
    }
}

struct AddApplicationView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var isPresented: Bool
    @State private var applicationName = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationView {
            Form {
                TextField("Application name", text: $applicationName)
                    .focused($isTextFieldFocused)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        if !applicationName.isEmpty {
                            Task {
                                await viewModel.createApplication(name: applicationName)
                            }
                            isPresented = false
                        }
                    }
                }
            }
            .navigationBarTitle("Create an application", displayMode: .inline)
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

struct ApplicationRowView: View {
    var application: ApplicationData

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(application.name)
                .foregroundColor(.primary)
                .font(.headline)
            HStack(spacing: 3) {
                if application.status == 1 {
                    Label("Enabled", systemImage: "circle.badge.checkmark.fill")
                        .foregroundColor(.green)
                } else {
                    Label("Disabled", systemImage: "circle.badge.xmark.fill")
                        .foregroundColor(.red)
                }
            }
            .font(.subheadline)
        }
    }
}
