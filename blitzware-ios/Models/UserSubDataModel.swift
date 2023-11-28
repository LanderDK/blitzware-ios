//
//  UserSubDataModel.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 28/11/2023.
//

import Foundation

struct UserSubData: Codable, Identifiable, Hashable {
    let id: Int
    var name: String
    var level: Int
    let applicationId: String
}
