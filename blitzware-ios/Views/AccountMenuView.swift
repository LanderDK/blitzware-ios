//
//  AccountMenuView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 14/11/2023.
//

import SwiftUI

struct AccountMenuView: View {
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {  
                NavigationLink(destination: AccountLogsView()) {
                    Text("Account Logs")
                }
                
                NavigationLink(destination: AccountDetailsView()) {
                    Text("Account Details")
                }
                
                NavigationLink(destination: AdminPanelView()) {
                    Text("Admin Panel")
                }
                
                Button(action: {
//                    logout()
                    showingLogoutAlert = true
                }) {
                    Text("Logout")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Account Settings")
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Logout"),
                    message: Text("Are you sure you want to logout?"),
                    primaryButton: .default(Text("Cancel")),
                    secondaryButton: .destructive(Text("Logout"), action: logout)
                )
            }
        }
    }
    
    func logout() {
        print("Logging out...")
        // TODO: - IMPLEMENT LOGOUT
    }
}
