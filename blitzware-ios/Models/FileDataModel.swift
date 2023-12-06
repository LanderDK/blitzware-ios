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
    
    var createdOnString: String
    var createdOn: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: createdOnString) ?? Date()
    }
    
    var application: Application
    struct Application: Codable {
        let id: String
        let name: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, size, createdOnString = "createdOn", application
    }
}
