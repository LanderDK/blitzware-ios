//
//  AppLogDataModel.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 06/12/2023.
//

import Foundation

struct AppLogData: Codable, Identifiable {
    let id: Int
    var username: String
    
    var dateString: String
    var date: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString) ?? Date()
    }
    
    var action: String
    var ip: String
    var appId: String
    
    enum CodingKeys: String, CodingKey {
        case id, username, dateString = "date", action, ip, appId
    }
}
