import Foundation
import CryptoKit

enum UserRole: String, CaseIterable {
    case staff
    case coordinator   // assumed specialization of staff (Task 2)
    case teacher       // assumed role (Task 1, Role B)
}

enum PasswordHasher {
    /// SHA-256 hex digest. Demo only: this lab keeps everything in memory.
    static func hash(_ password: String) -> String {
        SHA256.hash(data: Data(password.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}

/// Login identity and role (assumed, added per instructor for UC-07).
final class UserAccount: Identifiable {
    let username: String
    private let passwordHash: String
    let role: UserRole

    var id: String { username }

    init(username: String, passwordHash: String, role: UserRole) {
        self.username = username
        self.passwordHash = passwordHash
        self.role = role
    }

    func matches(password: String) -> Bool {
        PasswordHasher.hash(password) == passwordHash
    }

    // MARK: Permissions (Task 2 diagram: Coordinator inherits Staff; only Teacher enters marks)

    /// True only for the teacher role.
    var canEnterMarks: Bool { role == .teacher }
    /// Staff and Academic Coordinator (a specialization of staff).
    var canManageRecords: Bool { role == .staff || role == .coordinator }
    var canEnroll: Bool { canManageRecords }
    /// UC-04 is performed by the Academic Coordinator.
    var canAssignSubjects: Bool { role == .coordinator }

    var roleTitle: String {
        switch role {
        case .staff: return "School Staff"
        case .coordinator: return "Academic Coordinator"
        case .teacher: return "Teacher"
        }
    }
}

extension UserAccount {
    /// Demo accounts shown on the login screen.
    static let demoAccounts: [UserAccount] = [
        UserAccount(username: "staff", passwordHash: PasswordHasher.hash("staff123"), role: .staff),
        UserAccount(username: "coordinator", passwordHash: PasswordHasher.hash("coord123"), role: .coordinator),
        UserAccount(username: "teacher", passwordHash: PasswordHasher.hash("teacher123"), role: .teacher)
    ]
}
