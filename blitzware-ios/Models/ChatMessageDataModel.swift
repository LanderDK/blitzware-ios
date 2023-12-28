//
//  ChatMessageDataModel.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 13/11/2023.
//

import Foundation

struct ChatMessageData: Codable, Identifiable, Equatable {
    let id: Int
    var username: String
    var message: String
    var date: String
    var chatId: Int
}
