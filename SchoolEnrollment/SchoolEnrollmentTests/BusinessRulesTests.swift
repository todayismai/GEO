import XCTest
@testable import SchoolEnrollment

/// Automated versions of the Task 3 Step 7 test cases.
final class BusinessRulesTests: XCTestCase {

    // MARK: Helpers

    private func makeManager() throws -> SchoolManager {
        let manager = SchoolManager()
        try manager.addStudent(Student(id: "S1", name: "An", email: "an@school.edu"))
        try manager.addStudent(Student(id: "S2", name: "Binh", email: "binh@school.edu"))
        try manager.addTeacher(Teacher(id: "T1", name: "Duc", email: "duc@school.edu"))
        try manager.addTeacher(Teacher(id: "T2", name: "Ha", email: "ha@school.edu"))
        try manager.addSubject(Subject(id: "M1", title: "Math", credits: 3, semester: 1))
        try manager.addSubject(Subject(id: "P1", title: "Physics", credits: 3, semester: 1))
        return manager
    }

    private let year = "2026–2027"

    // MARK: Marks (FR-07, UC-06)

    func testMarkBoundariesAndDecimalAreAccepted() throws {
        let enrollment = try Enrollment(studentID: "S1", subjectID: "M1", academicYear: year)
        for value in [0.0, 10.0, 8.5] {
            try enrollment.updateMark(value)
            XCTAssertEqual(enrollment.mark, value)
        }
    }

    func testInvalidMarkIsRejectedAndPreviousMarkIsKept() throws {
        let enrollment = try Enrollment(studentID: "S1", subjectID: "M1", academicYear: year)
        try enrollment.updateMark(7)
        for bad in [11.0, -1.0, 10.01, Double.nan, Double.infinity] {
            XCTAssertThrowsError(try enrollment.updateMark(bad)) { error in
                XCTAssertEqual(error as? ValidationError, .markOutOfRange)
            }
            XCTAssertEqual(enrollment.mark, 7)
        }
    }

    func testMarkStartsAsNilUntilGraded() throws {
        let enrollment = try Enrollment(studentID: "S1", subjectID: "M1", academicYear: year)
        XCTAssertNil(enrollment.mark)
    }

    func testManagerUpdateMarkNeedsAnExistingEnrollment() throws {
        let manager = try makeManager()
        XCTAssertThrowsError(try manager.updateMark(5, studentID: "S1", subjectID: "M1", academicYear: year)) { error in
            XCTAssertEqual(error as? ValidationError, .notFound)
        }
        try manager.enroll(studentID: "S1", subjectID: "M1", academicYear: year)
        try manager.updateMark(9, studentID: "S1", subjectID: "M1", academicYear: year)
        XCTAssertEqual(manager.enrollments(for: "S1").first?.mark, 9)
    }

    // MARK: Enrollment (FR-05, FR-06, UC-05)

    func testDuplicateEnrollmentIsRejectedAndOriginalKept() throws {
        let manager = try makeManager()
        try manager.enroll(studentID: "S1", subjectID: "M1", academicYear: year)
        XCTAssertThrowsError(try manager.enroll(studentID: "S1", subjectID: "M1", academicYear: year)) { error in
            XCTAssertEqual(error as? ValidationError, .duplicateEnrollment(year: self.year))
        }
        XCTAssertEqual(manager.enrollments.count, 1)
    }

    func testSameSubjectInAnotherYearOrByAnotherStudentIsAccepted() throws {
        let manager = try makeManager()
        try manager.enroll(studentID: "S1", subjectID: "M1", academicYear: year)
        try manager.enroll(studentID: "S1", subjectID: "M1", academicYear: "2027–2028")
        try manager.enroll(studentID: "S2", subjectID: "M1", academicYear: year)
        try manager.enroll(studentID: "S1", subjectID: "P1", academicYear: year)
        XCTAssertEqual(manager.enrollments.count, 4)
    }

    func testUnknownStudentOrSubjectIsRejected() throws {
        let manager = try makeManager()
        XCTAssertThrowsError(try manager.enroll(studentID: "NOPE", subjectID: "M1", academicYear: year)) { error in
            XCTAssertEqual(error as? ValidationError, .notFound)
        }
        XCTAssertThrowsError(try manager.enroll(studentID: "S1", subjectID: "NOPE", academicYear: year)) { error in
            XCTAssertEqual(error as? ValidationError, .notFound)
        }
        XCTAssertTrue(manager.enrollments.isEmpty)
    }

    // MARK: Records (FR-02, FR-03, UC-02, UC-03)

    func testEmptyIDNameOrMalformedEmailCreatesNoStudent() {
        XCTAssertThrowsError(try Student(id: "", name: "An", email: "an@school.edu")) { error in
            XCTAssertEqual(error as? ValidationError, .emptyField("Student ID is required"))
        }
        XCTAssertThrowsError(try Student(id: "S1", name: "  ", email: "an@school.edu"))
        XCTAssertThrowsError(try Student(id: "S1", name: "An", email: "not-an-email")) { error in
            XCTAssertEqual(error as? ValidationError, .invalidEmail)
        }
    }

    func testDuplicateStudentIDIsRejected() throws {
        let manager = try makeManager()
        let duplicate = try Student(id: "S1", name: "Other", email: "other@school.edu")
        XCTAssertThrowsError(try manager.addStudent(duplicate)) { error in
            XCTAssertEqual(error as? ValidationError, .duplicateID)
        }
        XCTAssertEqual(manager.students.count, 2)
    }

    func testFailedEditChangesNothing() throws {
        let manager = try makeManager()
        XCTAssertThrowsError(try manager.updateStudent(id: "S1", name: "New Name", email: "bad"))
        XCTAssertEqual(manager.student(withID: "S1")?.name, "An")
        XCTAssertEqual(manager.student(withID: "S1")?.email, "an@school.edu")

        try manager.updateStudent(id: "S1", name: "New Name", email: "new@school.edu")
        XCTAssertEqual(manager.student(withID: "S1")?.name, "New Name")
    }

    func testSubjectCreditsMustBePositive() throws {
        XCTAssertThrowsError(try Subject(id: "X", title: "X", credits: 0, semester: 1)) { error in
            XCTAssertEqual(error as? ValidationError, .invalidCredits)
        }
        let subject = try Subject(id: "X", title: "X", credits: 2, semester: 1)
        XCTAssertThrowsError(try subject.updateCredits(-1))
        XCTAssertEqual(subject.credits, 2)
    }

    // MARK: Assignments (FR-04, UC-04)

    func testManyToManyAssignmentIsVisibleFromBothSides() throws {
        let manager = try makeManager()
        try manager.assign(subjectID: "M1", toTeacherID: "T1")
        try manager.assign(subjectID: "P1", toTeacherID: "T1")
        try manager.assign(subjectID: "M1", toTeacherID: "T2")
        try manager.assign(subjectID: "M1", toTeacherID: "T2")   // duplicate has no effect

        XCTAssertEqual(manager.subjects(for: "T1").map(\.id), ["M1", "P1"])
        XCTAssertEqual(manager.teachers(for: "M1").map(\.id), ["T1", "T2"])

        manager.unassign(subjectID: "M1", fromTeacherID: "T1")
        XCTAssertEqual(manager.teachers(for: "M1").map(\.id), ["T2"])
    }

    func testAssignWithoutSelectionOrWithUnknownIDsFails() throws {
        let manager = try makeManager()
        XCTAssertThrowsError(try manager.assign(subjectID: "", toTeacherID: "T1")) { error in
            XCTAssertEqual(error as? ValidationError, .emptyField("Select a teacher and at least one subject"))
        }
        XCTAssertThrowsError(try manager.assign(subjectID: "M1", toTeacherID: "NOPE")) { error in
            XCTAssertEqual(error as? ValidationError, .notFound)
        }
    }

    // MARK: Login and roles (UC-07)

    func testLoginSucceedsWithDemoAccountAndFailsWithWrongPassword() throws {
        let auth = AuthService(accounts: UserAccount.demoAccounts)
        XCTAssertThrowsError(try auth.login(username: "teacher", password: "wrong")) { error in
            XCTAssertEqual(error as? ValidationError, .invalidCredentials)
        }
        XCTAssertNil(auth.currentUser)

        let account = try auth.login(username: "Teacher", password: "teacher123")
        XCTAssertEqual(account.role, .teacher)
        XCTAssertNotNil(auth.currentUser)

        auth.logout()
        XCTAssertNil(auth.currentUser)
    }

    func testOnlyTeacherMayEnterMarksAndOnlyCoordinatorMayAssign() {
        let accounts = Dictionary(uniqueKeysWithValues: UserAccount.demoAccounts.map { ($0.role, $0) })
        XCTAssertTrue(accounts[.teacher]!.canEnterMarks)
        XCTAssertFalse(accounts[.staff]!.canEnterMarks)
        XCTAssertFalse(accounts[.coordinator]!.canEnterMarks)

        XCTAssertTrue(accounts[.coordinator]!.canAssignSubjects)
        XCTAssertFalse(accounts[.staff]!.canAssignSubjects)

        // The coordinator specializes staff, so it can also manage records and enroll.
        XCTAssertTrue(accounts[.coordinator]!.canManageRecords)
        XCTAssertTrue(accounts[.staff]!.canEnroll)
        XCTAssertFalse(accounts[.teacher]!.canManageRecords)
    }

    // MARK: Polymorphism

    func testDescribableGivesDifferentTextPerType() throws {
        let items: [Describable] = [
            try Student(id: "S1", name: "An", email: "an@school.edu"),
            try Teacher(id: "T1", name: "Duc", email: "duc@school.edu"),
            try Subject(id: "M1", title: "Math", credits: 3, semester: 1)
        ]
        XCTAssertEqual(items.map { $0.describe() }, [
            "S1 – An",
            "T1 – Duc (0 subjects)",
            "M1 – Math (3 credits)"
        ])
    }

    // MARK: Sample data

    func testSeededDataIsValid() {
        let manager = SchoolManager.seeded()
        XCTAssertEqual(manager.students.count, 3)
        XCTAssertEqual(manager.teachers.count, 2)
        XCTAssertEqual(manager.subjects.count, 4)
        XCTAssertEqual(manager.enrollments.count, 3)
        XCTAssertEqual(manager.teachers(for: "SUB101").count, 2)
    }
}
