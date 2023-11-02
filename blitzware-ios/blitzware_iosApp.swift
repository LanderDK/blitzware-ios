//
//  blitzware_iosApp.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 30/10/2023.
//

import SwiftUI

@main
struct blitzware_iosApp: App {
    let appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
        }
    }
}
