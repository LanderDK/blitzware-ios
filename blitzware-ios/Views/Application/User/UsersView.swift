//
//  UsersView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 25/11/2023.
//

import SwiftUI

struct UsersList: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isShowingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowingAddSheet = false
    @State private var isShowingEditSheet = false
    var application: ApplicationData
    @State private var userToEdit: UserDataMutate = UserDataMutate(id: "", username: "", email: "", expiryDate: "", hwid: "", twoFactorAuth: 0, enabled: 0, subscription: 0)
    
    var body: some View {
        VStack {
            HStack {
                Text("User Manager - \(application.name)")
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
                    Text(viewModel.errorData?.message ?? "Unknown error")
                        .foregroundColor(.red)
                }
                if viewModel.requestState == .pending || viewModel.requestState == .sent {
                    ProgressView()
                }
                List(viewModel.users, id: \.id) { user in
                    UserRowView(user: user)
                        .contextMenu {
                            CustomButton(title: "Edit") {
                                userToEdit = UserDataMutate(id: user.id, username: user.username, email: user.email, expiryDate: user.expiryDate, hwid: user.hwid, twoFactorAuth: user.twoFactorAuth, enabled: user.enabled, subscription: user.userSubId!)
                                isShowingEditSheet = true
                            }
                            
                            CustomButton(title: "Reset HWID") {
                                let newUser = UserDataMutate(id: user.id, username: user.username, email: user.email, expiryDate: user.expiryDate, hwid: "RESET", twoFactorAuth: user.twoFactorAuth, enabled: user.enabled, subscription: user.userSubId!)
                                Task {
                                    await viewModel.updateUserById(user: newUser)
                                    if viewModel.requestState == .success {
                                        if let index = viewModel.users.firstIndex(where: { $0.id == user.id }) {
                                            viewModel.users[index].hwid = "RESET"
                                        }
                                        alertTitle = "Success!"
                                        alertMessage = "User resetted successfully."
                                        isShowingAlert = true
                                    } else {
                                        alertTitle = "Oops!"
                                        alertMessage = viewModel.errorData?.message ?? "Unkown error"
                                        isShowingAlert = true
                                    }
                                }
                            }
                            if user.enabled == 1 {
                                CustomButton(title: "Ban") {
                                    let newUser = UserDataMutate(id: user.id, username: user.username, email: user.email, expiryDate: user.expiryDate, hwid: user.hwid, twoFactorAuth: user.twoFactorAuth, enabled: 0, subscription: user.userSubId!)
                                    Task {
                                        await viewModel.updateUserById(user: newUser)
                                        if viewModel.requestState == .success {
                                            if let index = viewModel.users.firstIndex(where: { $0.id == user.id }) {
                                                viewModel.users[index].enabled = 0
                                            }
                                            alertTitle = "Success!"
                                            alertMessage = "User banned successfully."
                                            isShowingAlert = true
                                        } else {
                                            alertTitle = "Oops!"
                                            alertMessage = viewModel.errorData?.message ?? "Unkown error"
                                            isShowingAlert = true
                                        }
                                    }
                                }
                            } else {
                                CustomButton(title: "Unban") {
                                    let newUser = UserDataMutate(id: user.id, username: user.username, email: user.email, expiryDate: user.expiryDate, hwid: user.hwid, twoFactorAuth: user.twoFactorAuth, enabled: 1, subscription: user.userSubId!)
                                    Task {
                                        await viewModel.updateUserById(user: newUser)
                                        if viewModel.requestState == .success {
                                            if let index = viewModel.users.firstIndex(where: { $0.id == user.id }) {
                                                viewModel.users[index].enabled = 1
                                            }
                                            alertTitle = "Success!"
                                            alertMessage = "User unbanned successfully."
                                            isShowingAlert = true
                                        } else {
                                            alertTitle = "Oops!"
                                            alertMessage = viewModel.errorData?.message ?? "Unkown error"
                                            isShowingAlert = true
                                        }
                                    }
                                }
                            }
                            CustomButton(title: "Delete") {
                                Task {
                                    await viewModel.deleteUserById(userId: user.id)
                                    if viewModel.requestState == .success {
                                        alertTitle = "Success!"
                                        alertMessage = "User deleted successfully."
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
                    await viewModel.getUsersOfApplication(applicationId: application.id)
                    await viewModel.getUserSubsOfApplication(applicationId: application.id)
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
                AddUserView(isPresented: $isShowingAddSheet)
            }
            .sheet(isPresented: $isShowingEditSheet) {
                EditUserView(isPresented: $isShowingEditSheet, user: $userToEdit)
            }
        }
    }
}

struct EditUserView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var isPresented: Bool
    @Binding var user: UserDataMutate
    private let options = [0,1]
    @State private var date = Date()

    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                Spacer()
                Text("Update an user")
                    .font(.headline)
                    .padding()
                Spacer()
                Button("Update") {
                    Task {
                        let dateString = dateToString(from: date) ?? "Invalid date"
                        user.expiryDate = dateString
                        await viewModel.updateUserById(user: user)
                        if let index = viewModel.users.firstIndex(where: { $0.id == user.id }) {
                            viewModel.users[index].username = user.username
                            viewModel.users[index].email = user.email
                            viewModel.users[index].expiryDate = user.expiryDate
                            viewModel.users[index].hwid = user.hwid
                            viewModel.users[index].twoFactorAuth = user.twoFactorAuth
                            viewModel.users[index].enabled = user.enabled
                            viewModel.users[index].userSubId = user.subscription
                        }
                    }
                    isPresented = false
                }
            }.padding()
            Form {
                TextField("Username", text: $user.username)
                TextField("Email", text: $user.email)
                DatePicker("Expiry date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(DefaultDatePickerStyle())
                    .onAppear {
                        date = stringToDate(from: user.expiryDate) ?? date
                    }
                TextField("Hardware-ID", text: $user.hwid)
                Picker("2FA", selection: $user.twoFactorAuth) {
                    ForEach(options, id: \.self) { option in
                        Text(option == 0 ? "False" : "True").tag(option)
                    }
                }.pickerStyle(MenuPickerStyle())
                Picker("Enabled", selection: $user.enabled) {
                    ForEach(options, id: \.self) { option in
                        Text(option == 0 ? "False" : "True").tag(option)
                    }
                }.pickerStyle(MenuPickerStyle())
                Picker("Subscription level", selection: $user.subscription) {
                    ForEach(viewModel.userSubs, id: \.self) { userSub in
                        Text("\(userSub.name) (\(userSub.level))").tag(userSub.id)
                    }
                }.pickerStyle(MenuPickerStyle())
            }
        }
    }
}

struct AddUserView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var isPresented: Bool
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var expiryDate = Date()
    @State private var subscription: Int = 0
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                Spacer()
                Text("Create an user")
                    .font(.headline)
                    .padding()
                Spacer()
                Button("Create") {
                    if !username.isEmpty && !email.isEmpty && !password.isEmpty && subscription != 0 {
                        Task {
                            await viewModel.createUserFromDashboard(username: username, email: email, password: password, id: viewModel.applicationData!.id, expiry: expiryDate, subscription: subscription)
                        }
                        isPresented = false
                    }
                }
            }
            .padding()
            
            Form {
                TextField("Username", text: $username)
                    .focused($isTextFieldFocused)
                TextField("Email", text: $email)
                SecureField("Password", text: $password)
                DatePicker("Expiry date", selection: $expiryDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(DefaultDatePickerStyle())
                Picker("Subscription level", selection: $subscription) {
                    Text("- Select a sub -")
                    ForEach(viewModel.userSubs, id: \.self) { userSub in
                        Text("\(userSub.name) (\(userSub.level))").tag(userSub.id)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}


struct UserRowView: View {
    @EnvironmentObject var viewModel: AppViewModel
    var user: UserData

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(user.username)
                .foregroundColor(.primary)
                .font(.headline)
            HStack {
                Text("Email: ")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(user.email)
                    .font(.subheadline)
            }
            HStack {
                Text("Expiry: ")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(convertDateString(user.expiryDate) ?? "Error date")
                    .font(.subheadline)
            }
            HStack {
                Text("Subscription: ")
                    .font(.subheadline)
                    .fontWeight(.bold)
                ForEach(viewModel.userSubs) { userSub in
                    if userSub.id == user.userSubId {
                        Text("\(userSub.name) (\(userSub.level))")
                            .font(.subheadline)
                    }
                }
            }
            HStack {
                Text("Last Login: ")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(convertDateString(user.lastLogin) ?? "Date error")
                    .font(.subheadline)
            }
            HStack {
                Text("IP: ")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(user.lastIP)
                    .font(.subheadline)
            }
            HStack {
                Text("HWID: ")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(user.hwid)
                    .font(.subheadline)
            }
        }
    }
}
