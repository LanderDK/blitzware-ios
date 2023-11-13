//
//  ChatMessageDataModel.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 13/11/2023.
//

import Foundation

struct ChatMessageData: Codable, Identifiable, Equatable {
    var id: Int
    var username: String
    var message: String
    var dateString: String // Represent date as a string
    var chatId: Int

    var date: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString) ?? Date()
    }

    enum CodingKeys: String, CodingKey {
        case id, username, message, dateString = "date", chatId
    }
}

