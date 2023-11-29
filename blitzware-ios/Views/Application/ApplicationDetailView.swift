//
//  ApplicationDetailView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 18/11/2023.
//

import SwiftUI

struct BottomNavBarApp: View {
    var application: ApplicationData
    
    var body: some View {
        NavigationView {
            TabView {
                ApplicationDetailView(application: application)
                    .tabItem {
                        Image(systemName: "square.grid.3x3.fill")
                        Text("Panel")
                    }
                UsersList(application: application)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Users")
                    }
                LicensesList(application: application)
                    .tabItem {
                        Image(systemName: "key.fill")
                        Text("Licenses")
                    }
                Text("Subscriptions")
                    .tabItem {
                        Image(systemName: "gift.fill")
                        Text("Subscriptions")
                    }
                Text("Files")
                    .tabItem {
                        Image(systemName: "paperclip")
                        Text("Files")
                    }
                Text("App Logs")
                    .tabItem {
                        Image(systemName: "list.clipboard")
                        Text("App Logs")
                    }
                Text("App Settings")
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("App Settings")
                    }
            }
            .accentColor(Constants.accentColor)
        }
    }
}

struct ApplicationDetailView: View {
    @EnvironmentObject var viewModel: AppViewModel
    var application: ApplicationData
//    let applicationId: String
//    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            if viewModel.requestState == .error {
                Text(viewModel.errorData?.message ?? "Unknown error")
                    .foregroundColor(.red)
            }
            if viewModel.requestState == .pending || viewModel.requestState == .sent {
                ProgressView()
            } else {
                VStack {
                    Text("Application Panel - \(application.name)")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, Constants.verticalPadding)
                    HStack {
                        Text("Name:")
                            .foregroundColor(.primary)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                            .padding(.leading, 10)
                            .padding(.bottom, 10)
                        Text(application.name)
                            .foregroundColor(.primary)
                            .font(.headline)
                            .padding(.top, 10)
                            .padding(.trailing, 10)
                            .padding(.bottom, 10)
                    }
                    .background(Constants.lightGray)
                    .cornerRadius(15)
//                    HStack {
//                        // NOT DECRYPTED BECAUSE NOT GETTING BY ID
//                        Text("Secret:")
//                            .foregroundColor(.primary)
//                            .font(.headline)
//                            .fontWeight(.bold)
//                        Text(application.secret)
//                            .foregroundColor(.primary)
//                            .font(.headline)
//                    }
                    HStack {
                        Text("Version:")
                            .foregroundColor(.primary)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                            .padding(.leading, 10)
                            .padding(.bottom, 10)
                        Text(application.version)
                            .foregroundColor(.primary)
                            .font(.headline)
                            .padding(.top, 10)
                            .padding(.trailing, 10)
                            .padding(.bottom, 10)
                    }
                    .background(Constants.lightGray)
                    .cornerRadius(15)
                    HStack {
                        Text("Status:")
                            .foregroundColor(.primary)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                            .padding(.leading, 10)
                            .padding(.bottom, 10)
                        if application.status == 1 {
                            Text("Enabled")
                                .foregroundColor(.green)
                                .font(.headline)
                                .padding(.top, 10)
                                .padding(.trailing, 10)
                                .padding(.bottom, 10)
                        } else {
                            Text("Disabled")
                                .foregroundColor(.red)
                                .font(.headline)
                                .padding(.top, 10)
                                .padding(.trailing, 10)
                                .padding(.bottom, 10)
                        }
                    }
                    .background(Constants.lightGray)
                    .cornerRadius(15)
                    HStack {
                        Text("Developer Mode:")
                            .foregroundColor(.primary)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                            .padding(.leading, 10)
                            .padding(.bottom, 10)
                        if application.developerMode == 1 {
                            Text("Enabled")
                                .foregroundColor(.green)
                                .font(.headline)
                                .padding(.top, 10)
                                .padding(.trailing, 10)
                                .padding(.bottom, 10)
                        } else {
                            Text("Disabled")
                                .foregroundColor(.red)
                                .font(.headline)
                                .padding(.top, 10)
                                .padding(.trailing, 10)
                                .padding(.bottom, 10)
                        }
                    }
                    .background(Constants.lightGray)
                    .cornerRadius(15)
                    HStack {
                        Text("2FA:")
                            .foregroundColor(.primary)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                            .padding(.leading, 10)
                            .padding(.bottom, 10)
                        if application.twoFactorAuth == 1 {
                            Text("Enabled")
                                .foregroundColor(.green)
                                .font(.headline)
                                .padding(.top, 10)
                                .padding(.trailing, 10)
                                .padding(.bottom, 10)
                        } else {
                            Text("Disabled")
                                .foregroundColor(.red)
                                .font(.headline)
                                .padding(.top, 10)
                                .padding(.trailing, 10)
                                .padding(.bottom, 10)
                        }
                    }
                    .background(Constants.lightGray)
                    .cornerRadius(15)
                    HStack {
                        Text("HWID Lock:")
                            .foregroundColor(.primary)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                            .padding(.leading, 10)
                            .padding(.bottom, 10)
                        if application.hwidCheck == 1 {
                            Text("Enabled")
                                .foregroundColor(.green)
                                .font(.headline)
                                .padding(.top, 10)
                                .padding(.trailing, 10)
                                .padding(.bottom, 10)
                        } else {
                            Text("Disabled")
                                .foregroundColor(.red)
                                .font(.headline)
                                .padding(.top, 10)
                                .padding(.trailing, 10)
                                .padding(.bottom, 10)
                        }
                    }
                    .background(Constants.lightGray)
                    .cornerRadius(15)
                    HStack {
                        Text("Free Mode:")
                            .foregroundColor(.primary)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                            .padding(.leading, 10)
                            .padding(.bottom, 10)
                        if application.freeMode == 1 {
                            Text("Enabled")
                                .foregroundColor(.green)
                                .font(.headline)
                                .padding(.top, 10)
                                .padding(.trailing, 10)
                                .padding(.bottom, 10)
                        } else {
                            Text("Disabled")
                                .foregroundColor(.red)
                                .font(.headline)
                                .padding(.top, 10)
                                .padding(.trailing, 10)
                                .padding(.bottom, 10)
                        }
                    }
                    .background(Constants.lightGray)
                    .cornerRadius(15)
                    HStack {
                        Text("Integrity Check:")
                            .foregroundColor(.primary)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                            .padding(.leading, 10)
                            .padding(.bottom, 10)
                        if application.integrityCheck == 1 {
                            Text("Enabled")
                                .foregroundColor(.green)
                                .font(.headline)
                                .padding(.top, 10)
                                .padding(.trailing, 10)
                                .padding(.bottom, 10)
                        } else {
                            Text("Disabled")
                                .foregroundColor(.red)
                                .font(.headline)
                                .padding(.top, 10)
                                .padding(.trailing, 10)
                                .padding(.bottom, 10)
                        }
                    }
                    .background(Constants.lightGray)
                    .cornerRadius(15)
                }
            }
        }
        .onAppear(perform: {
            Task {
                await viewModel.getApplicationById(id: application.id)
            }
        })
    }
}
