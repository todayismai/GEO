import Foundation

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

/// Small helpers shared by the model classes so every rule lives in one place.
enum Validator {
    /// Returns the trimmed text, or throws `.emptyField("<field> is required")`.
    static func requireNonEmpty(_ text: String, field: String) throws -> String {
        let value = text.trimmed
        guard !value.isEmpty else {
            throw ValidationError.emptyField("\(field) is required")
        }
        return value
    }

    /// Nonempty, valid-looking email (Task 3, Step 4).
    static func validEmail(_ text: String) throws -> String {
        let value = try requireNonEmpty(text, field: "Email")
        let pattern = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        guard value.range(of: pattern, options: .regularExpression) != nil else {
            throw ValidationError.invalidEmail
        }
        return value
    }

    /// Marks must be finite and inside 0...10 (boundaries included).
    static func validateMark(_ value: Double) throws {
        guard value.isFinite, (0.0...10.0).contains(value) else {
            throw ValidationError.markOutOfRange
        }
    }
}
