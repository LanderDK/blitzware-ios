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
    
    var expiryDateString: String
    var expiryDate: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: expiryDateString) ?? Date()
    }
    
    var lastLoginString: String
    var lastLogin: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: lastLoginString) ?? Date()
    }
    
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

    enum CodingKeys: String, CodingKey {
        case id, username, email, expiryDateString = "expiryDate", lastLoginString = "lastLogin", lastIP, hwid, license, enabled, twoFactorAuth, userSubId, application
    }
}

struct UserDataMutate: Codable, Identifiable {
    let id: String
    var username: String
    var email: String
    var expiryDate: Date
    var hwid: String
    var twoFactorAuth: Int
    var enabled: Int
    var subscription: Int?
}
