import Foundation

struct ApplicationData: Codable, Identifiable {
    let id: String
    let name: String
    let secret: String
    var status: Int
    var hwidCheck: Int
    var developerMode: Int
    var integrityCheck: Int
    var freeMode: Int
    var twoFactorAuth: Int
    var programHash: String?
    var version: String
    var downloadLink: String?
    let adminRoleId: Int?
    let adminRoleLevel: Int?
}
