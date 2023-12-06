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
    @State var userToEdit: UserDataMutate?
    
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
                                userToEdit = UserDataMutate(id: user.id, username: user.username, email: user.email, expiryDate: user.expiryDate, hwid: user.hwid, twoFactorAuth: user.twoFactorAuth, enabled: user.enabled, subscription: user.userSubId)
                                isShowingEditSheet = true
                            }
                            
                            CustomButton(title: "Reset HWID") {
                                let newUser = UserDataMutate(id: user.id, username: user.username, email: user.email, expiryDate: user.expiryDate, hwid: "RESET", twoFactorAuth: user.twoFactorAuth, enabled: user.enabled, subscription: user.userSubId)
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
                                    let newUser = UserDataMutate(id: user.id, username: user.username, email: user.email, expiryDate: user.expiryDate, hwid: user.hwid, twoFactorAuth: user.twoFactorAuth, enabled: 0, subscription: user.userSubId)
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
                                    let newUser = UserDataMutate(id: user.id, username: user.username, email: user.email, expiryDate: user.expiryDate, hwid: "RESET", twoFactorAuth: user.twoFactorAuth, enabled: 1, subscription: user.userSubId)
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
                EditUserView(user: userToEdit!, isPresented: $isShowingEditSheet)
            }
        }
    }
}

struct EditUserView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var isPresented: Bool
    @State var user: UserDataMutate
    @State var username: String
    @State var email: String
    @State var expiryDate: Date
    @State var hwid: String
    @State private var twoFactorAuth: Int
    @State private var enabled: Int
    @State private var subscription: Int
    private let options = ["0", "1"]

    init(user: UserDataMutate, isPresented: Binding<Bool>) {
        self._user = State(initialValue: user)
        self._username = State(initialValue: user.username)
        self._email = State(initialValue: user.email)
        self._expiryDate = State(initialValue: user.expiryDate)
        self._hwid = State(initialValue: user.hwid)
        self._twoFactorAuth = State(initialValue: user.twoFactorAuth)
        self._enabled = State(initialValue: user.enabled)
        self._subscription = State(initialValue: user.subscription ?? 0)
        self._isPresented = isPresented
    }

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
                    let newUser = UserDataMutate(id: user.id, username: username, email: email, expiryDate: expiryDate, hwid: hwid, twoFactorAuth: twoFactorAuth, enabled: enabled, subscription: subscription)
                    Task {
                        await viewModel.updateUserById(user: newUser)
                    }
                    isPresented = false
                }
            }
            .padding()
            
            Form {
                TextField("Username", text: $username)
                TextField("Email", text: $email)
                DatePicker("Expiry date", selection: $expiryDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(DefaultDatePickerStyle())
                    .labelsHidden()
                TextField("Hardware-ID", text: $hwid)
                DropDownInputBool(label: "2FA", name: "twoFactorAuth", options: options, selectedOption: $twoFactorAuth)
                    .frame(width: 200)
                DropDownInputBool(label: "Enabled", name: "enabled", options: options, selectedOption: $enabled)
                    .frame(width: 200)
                Picker("Subscription level", selection: $subscription) {
                    ForEach(viewModel.userSubs, id: \.self) { userSub in
                        Text("\(userSub.name) (\(userSub.level)")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
            }
        }.onDisappear(perform: {
            Task {
                await viewModel.getUsersOfApplication(applicationId: viewModel.users.first(where: {$0.username == username})!.application.id)
            }
        })
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
                    if !username.isEmpty || !email.isEmpty || !password.isEmpty || expiryDate != nil || subscription != 0 {
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
                    .labelsHidden()
                Picker("Subscription level", selection: $subscription) {
                    ForEach(viewModel.userSubs, id: \.self) { userSub in
                        Text("\(userSub.name) (\(userSub.level)")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
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
        //NavigationLink(destination: BottomNavBarApp(application: application)) {
            VStack(alignment: .leading, spacing: 3) {
                Text(user.username)
                    .foregroundColor(.primary)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
                Text(user.expiryDateString)
                    .font(.subheadline)
                ForEach(viewModel.userSubs) { userSub in
                    if userSub.id == user.userSubId {
                        Text("\(userSub.name) (\(userSub.level))")
                            .font(.subheadline)
                    }
                }
                Text(user.lastLoginString)
                    .font(.subheadline)
                Text(user.lastIP)
                    .font(.subheadline)
                Text(user.hwid)
                    .font(.subheadline)
            }
        //}
    }
}
