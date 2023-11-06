import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        if viewModel.isAuthed {
            AuthenticatedView()
        } else {
            LoginView()
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.badge.shield.checkmark.fill")
                    .font(.largeTitle)
                Text("Login to BlitzWare")
                    .font(.largeTitle)
            }
            HStack {
                Text("New here?")
                    .font(.subheadline)
                Text("Create an account")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 255/255, green: 94/255, blue: 0/255))
            }.padding(.bottom, 25)
            
            if viewModel.requestState == .error {
                Text(viewModel.errorData?.message ?? "Unkown error")
                    .foregroundColor(.red)
                    .padding(.bottom, 25)
            }
            else if viewModel.requestState == .success {
                Text("Successfully logged in!")
                    .foregroundColor(.green)
                    .padding(.bottom, 25)
            }
            
            VStack {
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            if viewModel.requestState == .pending || viewModel.requestState == .sent {
                ProgressView()
            }
            else {
                CustomButton(title: "Login", isDisabled: username.isEmpty || password.isEmpty) {
                    Task {
                        await viewModel.login(username: username, password: password)
                    }
                }
            }
        }.padding()
    }
}

struct AuthenticatedView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isShowingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowingAddSheet = false
    
    var body: some View {
        HStack {
            Text("Welcome back, \(viewModel.accountData!.account.username)!")
                .font(.title)
                .padding()
            Spacer()
            Button {
                isShowingAddSheet = true
            } label: {
                Image(systemName: "plus")
            }
            .font(.title)
            .padding()
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
                            CustomButton(title: "App-Panel") {
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

struct AddApplicationView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var isPresented: Bool
    @State private var applicationName = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Application name", text: $applicationName)
            }
            .navigationBarItems(
                trailing: Button("Create") {
                    if !applicationName.isEmpty {
                        Task {
                            await viewModel.createApplication(name: applicationName)
                        }
                        isPresented = false
                    }
                }
            )
            .navigationBarTitle("Create an application", displayMode: .inline)
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

struct CustomButton: View {
    var title: String
    var isDisabled: Bool = false
    var action: () async -> Void
    
    var body: some View {
        Button(action: {
            Task {
                await action()
            }
        }) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .padding()
                .background(isDisabled ? Color(red: 228/255, green: 228/255, blue: 228/255) :
                                Color(red: 25/255, green: 118/255, blue: 210/255))
                .foregroundColor(isDisabled ? .gray : .white)
                .cornerRadius(8)
        }
        .disabled(isDisabled)
    }
}

