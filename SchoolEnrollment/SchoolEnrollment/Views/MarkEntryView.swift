import SwiftUI

/// S11 Enter / Update Mark (+ S11-E invalid mark error) - UC-06, Teacher only.
struct MarkEntryView: View {
    @EnvironmentObject private var school: SchoolManager
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss

    let enrollment: Enrollment
    private let onSaved: (String) -> Void

    @State private var text: String
    @State private var errorMessage: String?

    init(enrollment: Enrollment, onSaved: @escaping (String) -> Void = { _ in }) {
        self.enrollment = enrollment
        self.onSaved = onSaved
        _text = State(initialValue: enrollment.mark.map { String(format: "%g", $0) } ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Enrollment") {
                    LabeledContent("Student", value: school.student(withID: enrollment.studentID)?.name ?? enrollment.studentID)
                    LabeledContent("Subject", value: school.subject(withID: enrollment.subjectID)?.title ?? enrollment.subjectID)
                    LabeledContent("Academic year", value: enrollment.academicYear)
                    LabeledContent("Current mark", value: MarkFormat.text(enrollment.mark))
                }

                Section("Mark (0–10)") {
                    TextField("e.g. 8.5", text: $text)
                        .keyboardType(.decimalPad)
                }

                if errorMessage != nil {
                    Section { ErrorBanner(message: errorMessage) }
                }
            }
            .navigationTitle("Enter / Update Mark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }      // mark unchanged
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                }
            }
        }
    }

    private func save() {
        guard auth.currentUser?.canEnterMarks == true else {
            errorMessage = "Only teachers can enter marks."
            return
        }
        let cleaned = text.trimmed.replacingOccurrences(of: ",", with: ".")
        guard !cleaned.isEmpty else {
            errorMessage = "Mark is required"
            return
        }
        do {
            guard let value = Double(cleaned) else { throw ValidationError.markOutOfRange }
            try school.updateMark(
                value,
                studentID: enrollment.studentID,
                subjectID: enrollment.subjectID,
                academicYear: enrollment.academicYear
            )
            onSaved("Mark saved")
            dismiss()
        } catch {
            errorMessage = error.localizedDescription   // "Mark must be 0–10"; saved mark unchanged
        }
    }
}
