import Foundation

final class Student: Identifiable, Describable {
    let id: String
    private(set) var name: String
    private(set) var email: String

    /// Rejects empty fields and malformed email; no object is created on failure.
    init(id: String, name: String, email: String) throws {
        self.id = try Validator.requireNonEmpty(id, field: "Student ID")
        self.name = try Validator.requireNonEmpty(name, field: "Name")
        self.email = try Validator.validEmail(email)
    }

    func updateName(_ value: String) throws {
        name = try Validator.requireNonEmpty(value, field: "Name")
    }

    func updateEmail(_ value: String) throws {
        email = try Validator.validEmail(value)
    }

    func describe() -> String { "\(id) – \(name)" }
}
