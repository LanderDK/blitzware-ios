//
//  AuthenticationView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 09/11/2023.
//

import SwiftUI

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
                    .foregroundColor(Constants.mainColorLight)
            }.padding(.bottom, Constants.verticalPadding)
            
            if viewModel.requestState == .error {
                Text(viewModel.errorData?.message ?? "Unknown error")
                    .foregroundColor(.red)
                    .padding(.bottom, Constants.verticalPadding)
            }
            else if viewModel.requestState == .success {
                Text("Successfully logged in!")
                    .foregroundColor(.green)
                    .padding(.bottom, Constants.verticalPadding)
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
