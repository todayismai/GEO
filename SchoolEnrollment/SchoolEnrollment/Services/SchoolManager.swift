import Foundation

/// Controller that holds all records in memory and enforces cross-record rules
/// (duplicate IDs, duplicate enrollment, assignments). Views only call these methods.
final class SchoolManager: ObservableObject {
    static let academicYears = ["2026–2027", "2027–2028"]
    static let defaultYear = academicYears[0]

    @Published private(set) var students: [Student] = []
    @Published private(set) var teachers: [Teacher] = []
    @Published private(set) var subjects: [Subject] = []
    @Published private(set) var enrollments: [Enrollment] = []

    init() {}

    // MARK: Lookups

    func student(withID id: String) -> Student? { students.first { $0.id == id } }
    func teacher(withID id: String) -> Teacher? { teachers.first { $0.id == id } }
    func subject(withID id: String) -> Subject? { subjects.first { $0.id == id } }

    // MARK: Records (UC-02, UC-03)

    func addStudent(_ student: Student) throws {
        guard self.student(withID: student.id) == nil else { throw ValidationError.duplicateID }
        students.append(student)
    }

    func addTeacher(_ teacher: Teacher) throws {
        guard self.teacher(withID: teacher.id) == nil else { throw ValidationError.duplicateID }
        teachers.append(teacher)
    }

    func addSubject(_ subject: Subject) throws {
        guard self.subject(withID: subject.id) == nil else { throw ValidationError.duplicateID }
        subjects.append(subject)
    }

    /// Validates both fields first, so a failure changes nothing (FR-03).
    func updateStudent(id: String, name: String, email: String) throws {
        guard let student = self.student(withID: id) else { throw ValidationError.notFound }
        _ = try Validator.requireNonEmpty(name, field: "Name")
        _ = try Validator.validEmail(email)
        objectWillChange.send()
        try student.updateName(name)
        try student.updateEmail(email)
    }

    // MARK: Teaching assignments (UC-04, FR-04)

    func assign(subjectID: String, toTeacherID teacherID: String) throws {
        guard !subjectID.trimmed.isEmpty, !teacherID.trimmed.isEmpty else {
            throw ValidationError.emptyField("Select a teacher and at least one subject")
        }
        guard let teacher = self.teacher(withID: teacherID), self.subject(withID: subjectID) != nil else {
            throw ValidationError.notFound
        }
        objectWillChange.send()
        teacher.assign(subjectID: subjectID)
    }

    func unassign(subjectID: String, fromTeacherID teacherID: String) {
        guard let teacher = self.teacher(withID: teacherID) else { return }
        objectWillChange.send()
        teacher.unassign(subjectID: subjectID)
    }

    /// Teachers of a subject (the "vice versa" of FR-04).
    func teachers(for subjectID: String) -> [Teacher] {
        teachers.filter { $0.subjectIDs.contains(subjectID) }
    }

    func subjects(for teacherID: String) -> [Subject] {
        guard let teacher = self.teacher(withID: teacherID) else { return [] }
        return subjects.filter { teacher.subjectIDs.contains($0.id) }
    }

    // MARK: Enrollment (UC-05, FR-05, FR-06)

    /// Unknown student/subject -> .notFound; same student + subject + year -> .duplicateEnrollment
    /// and the original is kept; otherwise the enrollment is added.
    @discardableResult
    func enroll(studentID: String, subjectID: String, academicYear: String) throws -> Enrollment {
        let enrollment = try Enrollment(studentID: studentID, subjectID: subjectID, academicYear: academicYear)
        guard self.student(withID: enrollment.studentID) != nil,
              self.subject(withID: enrollment.subjectID) != nil else {
            throw ValidationError.notFound
        }
        guard !enrollments.contains(where: { $0.id == enrollment.id }) else {
            throw ValidationError.duplicateEnrollment(year: enrollment.academicYear)
        }
        enrollments.append(enrollment)
        return enrollment
    }

    func enrollments(for studentID: String) -> [Enrollment] {
        enrollments.filter { $0.studentID == studentID }
    }

    // MARK: Marks (UC-06, FR-07)

    func updateMark(_ value: Double, studentID: String, subjectID: String, academicYear: String) throws {
        let key = "\(studentID)|\(subjectID)|\(academicYear)"
        guard let enrollment = enrollments.first(where: { $0.id == key }) else {
            throw ValidationError.notFound
        }
        objectWillChange.send()
        try enrollment.updateMark(value)   // throws .markOutOfRange; the previous mark is preserved
    }
}

// MARK: - Sample data (the lab is in-memory only)

extension SchoolManager {
    static func seeded() -> SchoolManager {
        let manager = SchoolManager()
        do {
            try manager.addStudent(Student(id: "S001", name: "Nguyen Van An", email: "an.nguyen@school.edu"))
            try manager.addStudent(Student(id: "S002", name: "Tran Thi Binh", email: "binh.tran@school.edu"))
            try manager.addStudent(Student(id: "S003", name: "Le Hoang Cuong", email: "cuong.le@school.edu"))

            try manager.addTeacher(Teacher(id: "T001", name: "Pham Minh Duc", email: "duc.pham@school.edu"))
            try manager.addTeacher(Teacher(id: "T002", name: "Vo Thu Ha", email: "ha.vo@school.edu"))

            try manager.addSubject(Subject(id: "SUB101", title: "Mathematics", credits: 3, semester: 1))
            try manager.addSubject(Subject(id: "SUB102", title: "Physics", credits: 3, semester: 1))
            try manager.addSubject(Subject(id: "SUB201", title: "iOS Programming", credits: 4, semester: 2))
            try manager.addSubject(Subject(id: "SUB202", title: "Geo-information", credits: 3, semester: 2))

            // Many-to-many: SUB101 has two teachers, T002 teaches three subjects.
            try manager.assign(subjectID: "SUB101", toTeacherID: "T001")
            try manager.assign(subjectID: "SUB102", toTeacherID: "T001")
            try manager.assign(subjectID: "SUB101", toTeacherID: "T002")
            try manager.assign(subjectID: "SUB201", toTeacherID: "T002")
            try manager.assign(subjectID: "SUB202", toTeacherID: "T002")

            let year = SchoolManager.defaultYear
            try manager.enroll(studentID: "S001", subjectID: "SUB101", academicYear: year)
            try manager.enroll(studentID: "S001", subjectID: "SUB201", academicYear: year)
            try manager.enroll(studentID: "S002", subjectID: "SUB101", academicYear: year)
            try manager.updateMark(8.5, studentID: "S001", subjectID: "SUB101", academicYear: year)
            try manager.updateMark(7, studentID: "S002", subjectID: "SUB101", academicYear: year)
        } catch {
            assertionFailure("Sample data is invalid: \(error)")
        }
        return manager
    }
}
