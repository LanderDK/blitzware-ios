//
//  ExtentionsView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 09/11/2023.
//

import SwiftUI

struct Constants {
    static let accentColor = Color(red: 253/255, green: 126/255, blue: 20/255)
    static let mainColorLight = Color(red: 255/255, green: 94/255, blue: 0/255)
    static let lightGray = Color(red: 211/255, green: 211/255, blue: 211/255)
    static let verticalPadding: CGFloat = 25.0
}

struct CustomButton: View {
    var title: String
    var isDisabled: Bool = false
    var action: () async -> Void
    
    var body: some View {
        Button(action: {
            Task {
                await action()
            }
        }) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .padding()
                .background(isDisabled ? Color(red: 228/255, green: 228/255, blue: 228/255) :
                                Color(red: 25/255, green: 118/255, blue: 210/255))
                .foregroundColor(isDisabled ? .gray : .white)
                .cornerRadius(8)
        }
        .disabled(isDisabled)
    }
}
