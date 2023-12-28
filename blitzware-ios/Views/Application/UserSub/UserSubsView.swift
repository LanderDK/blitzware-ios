//
//  UserSubsView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 06/12/2023.
//

import SwiftUI

struct UserSubsList: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isShowingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowingAddSheet = false
    @State private var isShowingEditSheet = false
    var application: ApplicationData
    @State private var userSubToEdit: UserSubData = UserSubData(id: 0, name: "", level: 0, applicationId: "")
    
    var body: some View {
        VStack {
            HStack {
                Text("Subscription Manager - \(application.name)")
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
                List(viewModel.userSubs, id: \.id) { userSub in
                    UserSubRowView(userSub: userSub)
                        .contextMenu {
                            CustomButton(title: "Edit") {
                                userSubToEdit = userSub
                                isShowingEditSheet = true
                            }
                            CustomButton(title: "Delete") {
                                Task {
                                    await viewModel.deleteUserSubById(userSubId: userSub.id)
                                    if viewModel.requestState == .success {
                                        alertTitle = "Success!"
                                        alertMessage = "Subscription deleted successfully."
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
                AddUserSubView(isPresented: $isShowingAddSheet)
            }
            .sheet(isPresented: $isShowingEditSheet) {
                EditUserSubView(isPresented: $isShowingEditSheet, userSub: $userSubToEdit)
            }
        }
    }
}

struct EditUserSubView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var isPresented: Bool
    @Binding var userSub: UserSubData

    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                Spacer()
                Text("Edit subscription")
                    .font(.headline)
                    .padding()
                Spacer()
                Button("Update") {
                    Task {
                        await viewModel.updateUserSubById(userSub: userSub)
                    }
                    isPresented = false
                }
            }.padding()
            Form {
                TextField("Name", text: $userSub.name)
                HStack {
                    Text("Level")
                    Spacer()
                    TextField("Level", text: Binding<String>(
                        get: { String(self.userSub.level) },
                        set: { if let value = Int($0) { self.userSub.level = value } }
                    ))
                }
                
            }
        }
//        .onDisappear(perform: {
//            Task {
//                await viewModel.getUsersOfApplication(applicationId: viewModel.users.first(where: {$0.username == username})!.application.id)
//            }
//        })
    }
}

struct AddUserSubView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var level = 0
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                Spacer()
                Text("Create a subscription")
                    .font(.headline)
                    .padding()
                Spacer()
                Button("Create") {
                    if !name.isEmpty && level >= 0 && level <= 9  {
                        Task {
                            await viewModel.createUserSub(name: name, level: level, applicationId: viewModel.applicationData!.id)
                        }
                        isPresented = false
                    }
                }
            }
            .padding()
            
            Form {
                TextField("Name", text: $name)
                    .focused($isTextFieldFocused)
                HStack {
                    Text("Level")
                    Spacer()
                    TextField("Level", text: Binding<String>(
                        get: { String(self.level) },
                        set: { if let value = Int($0) { self.level = value } }
                    ))
                }
                
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}


struct UserSubRowView: View {
    @EnvironmentObject var viewModel: AppViewModel
    var userSub: UserSubData

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(userSub.name)
                .foregroundColor(.primary)
                .font(.headline)
            HStack {
                Text("Level: ")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text("\(userSub.level)")
                    .font(.subheadline)
            }
        }
    }
}
