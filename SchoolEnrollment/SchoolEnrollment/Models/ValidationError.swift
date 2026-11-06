import Foundation

/// Every reason an operation can be rejected (Task 3, Steps 4 and 7).
/// `emptyField` carries the full message so the UI can show e.g. "Student ID is required".
enum ValidationError: Error, Equatable {
    case emptyField(String)
    case invalidEmail
    case markOutOfRange
    case invalidCredits
    case duplicateID
    case duplicateEnrollment(year: String)
    case notFound
    case invalidCredentials
}

extension ValidationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyField(let message):
            return message
        case .invalidEmail:
            return "Please enter a valid email address."
        case .markOutOfRange:
            return "Mark must be 0–10"
        case .invalidCredits:
            return "Credits must be greater than 0."
        case .duplicateID:
            return "This ID already exists."
        case .duplicateEnrollment(let year):
            return "Already enrolled in this subject for \(year)"
        case .notFound:
            return "The selected record was not found."
        case .invalidCredentials:
            return "Incorrect username or password"
        }
    }
}
