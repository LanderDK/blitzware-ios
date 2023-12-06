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
    
    var body: some View {
        VStack {
            if viewModel.requestState == .error {
                Text(viewModel.errorData?.message ?? "Unknown error")
                    .foregroundColor(.red)
            }
            if viewModel.requestState == .pending || viewModel.requestState == .sent {
                ProgressView()
            }
            VStack {
                Text("Application Panel - \(viewModel.applicationData?.name ?? "N/A")")
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
                    Text(viewModel.applicationData?.name ?? "N/A")
                        .foregroundColor(.primary)
                        .font(.headline)
                        .padding(.top, 10)
                        .padding(.trailing, 10)
                        .padding(.bottom, 10)
                }
                .background(Constants.lightGray)
                .cornerRadius(15)
                HStack {
                    Text("Secret:")
                        .foregroundColor(.primary)
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                        .padding(.leading, 10)
                        .padding(.bottom, 10)
                    Text(viewModel.applicationData?.secret ?? "N/A")
                        .foregroundColor(.primary)
                        .font(.headline)
                        .padding(.top, 10)
                        .padding(.trailing, 10)
                        .padding(.bottom, 10)
                }
                HStack {
                    Text("Version:")
                        .foregroundColor(.primary)
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                        .padding(.leading, 10)
                        .padding(.bottom, 10)
                    Text(viewModel.applicationData?.version ?? "N/A")
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
                    if viewModel.applicationData?.status ?? 0 == 1 {
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
                    if viewModel.applicationData?.developerMode ?? 0 == 1 {
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
                    if viewModel.applicationData?.twoFactorAuth ?? 0 == 1 {
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
                    if viewModel.applicationData?.hwidCheck ?? 0 == 1 {
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
                    if viewModel.applicationData?.freeMode ?? 0 == 1 {
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
                    if viewModel.applicationData?.integrityCheck ?? 0 == 1 {
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
        .onAppear(perform: {
            Task {
                await viewModel.getApplicationById(id: application.id)
            }
        })
    }
}
