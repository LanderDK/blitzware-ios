//
//  LicenseDataModel.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 28/11/2023.
//

import Foundation

struct LicenseData: Codable, Identifiable {
    let id: String
    var license: String
    var days: Int
    
    var expiryDateString: String
    var expiryDate: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: expiryDateString) ?? Date()
    }
    
    var used: Int
    var usedBy: String?
    var enabled: Int
    var userSubId: Int?
    
    var application: Application
    struct Application: Codable {
        let id: String
        let name: String
    }

    enum CodingKeys: String, CodingKey {
        case id, expiryDateString = "expiryDate", license, enabled, userSubId, application, days, used, usedBy
    }
}

struct LicenseDataMutate: Codable, Identifiable {
    let id: String
    var license: String
    var days: Int
    var used: Int
    var enabled: Int
    var subscription: Int?
}
