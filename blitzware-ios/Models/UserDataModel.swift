//
//  UserDataModel.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 25/11/2023.
//

import Foundation

struct UserData: Codable, Identifiable {
    let id: String
    var username: String
    var email: String
    var expiryDate: String
    var lastLogin: String
    var lastIP: String
    var hwid: String
    var license: String
    var enabled: Int
    var twoFactorAuth: Int
    var userSubId: Int?
    
    var application: Application
    struct Application: Codable {
        let id: String
        let name: String
    }
}

struct UserDataMutate: Codable, Identifiable {
    let id: String
    var username: String
    var email: String
    var expiryDate: String
    var hwid: String
    var twoFactorAuth: Int
    var enabled: Int
    var subscription: Int
}
