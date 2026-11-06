import SwiftUI

/// S10 Enroll Student (+ S10-E duplicate enrollment error) - UC-05.
struct EnrollmentView: View {
    @EnvironmentObject private var school: SchoolManager
    @Environment(\.dismiss) private var dismiss

    private let onSaved: (String) -> Void

    @State private var studentID: String?
    @State private var subjectID: String?
    @State private var year = SchoolManager.defaultYear
    @State private var errorMessage: String?

    init(studentID: String? = nil, onSaved: @escaping (String) -> Void = { _ in }) {
        self.onSaved = onSaved
        _studentID = State(initialValue: studentID)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Student", selection: $studentID) {
                        Text("Select…").tag(String?.none)
                        ForEach(school.students) { student in
                            Text(student.describe()).tag(Optional(student.id))
                        }
                    }
                    Picker("Subject", selection: $subjectID) {
                        Text("Select…").tag(String?.none)
                        ForEach(school.subjects) { subject in
                            Text(subject.describe()).tag(Optional(subject.id))
                        }
                    }
                    Picker("Academic year", selection: $year) {
                        ForEach(SchoolManager.academicYears, id: \.self) { value in
                            Text(value).tag(value)
                        }
                    }
                }

                if errorMessage != nil {
                    Section { ErrorBanner(message: errorMessage) }
                }
            }
            .navigationTitle("Enroll Student")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enroll", action: enroll)
                }
            }
        }
    }

    private func enroll() {
        guard let chosenStudent = studentID else {
            errorMessage = "Select a student"
            return
        }
        guard let chosenSubject = subjectID else {
            errorMessage = "Select a subject"
            return
        }
        do {
            try school.enroll(studentID: chosenStudent, subjectID: chosenSubject, academicYear: year)
            onSaved("Student enrolled")
            dismiss()
        } catch {
            // Duplicate: "Already enrolled in this subject for 2026–2027"; no record is created.
            errorMessage = error.localizedDescription
        }
    }
}
