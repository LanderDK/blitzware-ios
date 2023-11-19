import Foundation

struct AccountLoginData: Codable {
    var account: Account
    let token: String
    
    struct Account: Codable {
        let id: String
        var username: String
        var email: String
        var roles: [String]
        var creationDate: String
        var profilePicture: String?
        var emailVerified: Int
        var twoFactorAuth: Int
        var enabled: Int
    }
}
