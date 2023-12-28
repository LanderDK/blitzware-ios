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
    var date: String
    var action: String
    var ip: String
    var appId: String
}
