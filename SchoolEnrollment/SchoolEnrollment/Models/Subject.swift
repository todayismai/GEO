import Foundation

final class Subject: Identifiable, Describable {
    let id: String
    private(set) var title: String
    private(set) var credits: Int
    private(set) var semester: Int

    /// credits must be > 0 (proposed design rule, labelled as an assumption in Task 3).
    init(id: String, title: String, credits: Int, semester: Int) throws {
        self.id = try Validator.requireNonEmpty(id, field: "Subject ID")
        self.title = try Validator.requireNonEmpty(title, field: "Title")
        guard credits > 0 else { throw ValidationError.invalidCredits }
        guard semester > 0 else { throw ValidationError.emptyField("Semester must be 1 or more") }
        self.credits = credits
        self.semester = semester
    }

    func updateCredits(_ value: Int) throws {
        guard value > 0 else { throw ValidationError.invalidCredits }
        credits = value
    }

    func describe() -> String { "\(id) – \(title) (\(credits) credits)" }
}
