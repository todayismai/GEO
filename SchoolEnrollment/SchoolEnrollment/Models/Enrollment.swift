import Foundation

/// A student taking a subject in one academic year, with an optional mark (nil = not graded yet).
final class Enrollment: Identifiable {
    let studentID: String
    let subjectID: String
    let academicYear: String
    /// Encapsulation: the mark can only change through `updateMark(_:)`.
    private(set) var mark: Double?

    var id: String { "\(studentID)|\(subjectID)|\(academicYear)" }

    init(studentID: String, subjectID: String, academicYear: String) throws {
        self.studentID = try Validator.requireNonEmpty(studentID, field: "Student")
        self.subjectID = try Validator.requireNonEmpty(subjectID, field: "Subject")
        self.academicYear = try Validator.requireNonEmpty(academicYear, field: "Academic year")
        self.mark = nil
    }

    /// Accepts 0...10 only; on failure the previous mark is preserved.
    func updateMark(_ value: Double) throws {
        try Validator.validateMark(value)
        mark = value
    }
}
