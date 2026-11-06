import Foundation

final class Teacher: Identifiable, Describable {
    let id: String
    private(set) var name: String
    private(set) var email: String
    /// Many-to-many link to subjects, stored by ID to avoid circular references.
    private(set) var subjectIDs: Set<String> = []

    init(id: String, name: String, email: String) throws {
        self.id = try Validator.requireNonEmpty(id, field: "Teacher ID")
        self.name = try Validator.requireNonEmpty(name, field: "Name")
        self.email = try Validator.validEmail(email)
    }

    /// Set semantics: assigning the same subject twice has no effect (design assumption).
    func assign(subjectID: String) { subjectIDs.insert(subjectID) }
    func unassign(subjectID: String) { subjectIDs.remove(subjectID) }

    func describe() -> String {
        let count = subjectIDs.count
        return "\(id) – \(name) (\(count) subject\(count == 1 ? "" : "s"))"
    }
}
