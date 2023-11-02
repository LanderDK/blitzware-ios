import Foundation

struct AccountData: Codable {
    let account: Account
    let token: String
    
    struct Account: Codable {
        let id: String
        let username: String
        let email: String
        let roles: [String]
        let creationDate: String
        let profilePicture: String?
        let emailVerified: Int
        let twoFactorAuth: Int
        let enabled: Int
    }
}
