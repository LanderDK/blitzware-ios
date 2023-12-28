//
//  FileDataModel.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 06/12/2023.
//

import Foundation

struct FileData: Codable, Identifiable {
    let id: String
    var name: String
    var size: String
    var createdOn: String
    var application: Application
    struct Application: Codable {
        let id: String
        let name: String
    }
}
