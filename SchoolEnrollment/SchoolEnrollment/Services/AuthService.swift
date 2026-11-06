import Foundation

/// UC-07 Login: verifies credentials and keeps the signed-in user.
final class AuthService: ObservableObject {
    @Published private(set) var currentUser: UserAccount?
    private var accounts: [UserAccount]

    init(accounts: [UserAccount]) {
        self.accounts = accounts
    }

    /// Wrong username or password throws `.invalidCredentials`; nobody is signed in.
    @discardableResult
    func login(username: String, password: String) throws -> UserAccount {
        let name = username.trimmed.lowercased()
        guard let account = accounts.first(where: { $0.username.lowercased() == name }),
              account.matches(password: password) else {
            throw ValidationError.invalidCredentials
        }
        currentUser = account
        return account
    }

    func logout() {
        currentUser = nil
    }
}
