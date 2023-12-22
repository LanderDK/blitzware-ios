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
    @State private var twoFactorCode = ""
    @State private var otpCode = ""
    
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
        }
        .padding()
        .alert("Two-Factor Authentication", isPresented: $viewModel.twoFactorRequired, actions: {
            TextField("000000", text: $twoFactorCode)
            Button("Login", action: verify2FA)
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Please enter the 6-digit code:")
        })
        .alert("Action required: check email", isPresented: $viewModel.otpRequired, actions: {
            TextField("0000", text: $otpCode)
            Button("Login", action: verifyOTP)
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Please enter the 4-digit code:")
        })
    }
    
    func verify2FA() {
        Task {
            await viewModel.verifyLogin2FA(username: username, twoFactorCode: twoFactorCode)
        }
    }
    
    func verifyOTP() {
        Task {
            await viewModel.verifyLoginOTP(username: username, otp: otpCode)
        }
    }
}
