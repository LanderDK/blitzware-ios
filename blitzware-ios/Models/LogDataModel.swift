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
    var date: String
    var action: String
    var message: String
}
