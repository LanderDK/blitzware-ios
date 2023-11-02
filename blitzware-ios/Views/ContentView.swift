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
                Text(viewModel.errorData!.message)
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
    
    var body: some View {
        Text("Welcome back, \(viewModel.accountData!.account.username)")
            .font(.largeTitle)
            .padding()
        VStack {
            if viewModel.requestState == .error {
                Text(viewModel.errorData!.message)
                    .foregroundColor(.red)
            }
            if viewModel.requestState == .pending || viewModel.requestState == .sent {
                ProgressView()
            } else {
                List(viewModel.applications, id: \.id) { application in
                    ApplicationRowView(application: application)
                } 
            }
        }.onAppear(perform: {
            Task {
                await viewModel.getApplicationsOfAccount()
            }
        })
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
    var isDisabled: Bool
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

