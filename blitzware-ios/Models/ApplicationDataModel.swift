import Foundation

struct ApplicationData: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let secret: String
    let status: Int
    let hwidCheck: Int
    let developerMode: Int
    let integrityCheck: Int
    let freeMode: Int
    let twoFactorAuth: Int
    let programHash: String?
    let version: String
    let downloadLink: String?
    let adminRoleId: Int?
    let adminRoleLevel: Int?
}
