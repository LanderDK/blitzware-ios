//
//  LogDataModel.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 15/11/2023.
//

import Foundation

struct LogData: Codable, Identifiable {
    let id: Int
    var username: String
    var dateString: String // Represent date as a string
    var action: String
    var message: String
    
    var date: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString) ?? Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id, username, dateString = "date", action, message
    }
}
