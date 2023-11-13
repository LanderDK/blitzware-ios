import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        if viewModel.isAuthed {
            BottomNavBar()
        } else {
            LoginView()
        }
    }
}

struct BottomNavBar: View {
    var body: some View {
        NavigationView {
            TabView {
                ApplicationsList()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Apps")
                    }
                ResourcesList()
                    .tabItem {
                        Image(systemName: "book.fill")
                        Text("Resources")
                    }
                CommunityView()
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text("Community")
                    }
                Text("Account")
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Account")
                    }
            }
            .accentColor(Color(red: 253/255, green: 126/255, blue: 20/255))
        }
    }
}
