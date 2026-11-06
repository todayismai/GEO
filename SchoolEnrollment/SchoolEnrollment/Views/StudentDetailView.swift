import SwiftUI

/// S02 Student Detail: student info plus enrolled subjects and marks.
/// Staff/Coordinator can Edit and Enroll; a Teacher taps an enrollment to enter a mark (UC-06).
struct StudentDetailView: View {
    @EnvironmentObject private var school: SchoolManager
    @EnvironmentObject private var auth: AuthService

    let student: Student

    @State private var showEdit = false
    @State private var showEnroll = false
    @State private var markTarget: Enrollment?
    @State private var toast: String?

    private var user: UserAccount? { auth.currentUser }

    var body: some View {
        List {
            Section("Student") {
                LabeledContent("ID", value: student.id)
                LabeledContent("Name", value: student.name)
                LabeledContent("Email", value: student.email)
            }

            Section("Enrolled subjects and marks") {
                let items = school.enrollments(for: student.id)
                if items.isEmpty {
                    Text("No enrollments yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(items) { enrollment in
                        if user?.canEnterMarks == true {
                            Button {
                                markTarget = enrollment
                            } label: {
                                row(for: enrollment, showChevron: true)
                            }
                            .foregroundStyle(.primary)
                        } else {
                            row(for: enrollment, showChevron: false)
                        }
                    }
                }
            }

            if user?.canEnterMarks == true {
                Section {
                    Text("Tap an enrollment to enter or update its mark.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(student.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if user?.canManageRecords == true {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Enroll") { showEnroll = true }
                    Button("Edit") { showEdit = true }
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            StudentFormView(editing: student, onSaved: { toast = $0 })
        }
        .sheet(isPresented: $showEnroll) {
            EnrollmentView(studentID: student.id, onSaved: { toast = $0 })
        }
        .sheet(item: $markTarget) { enrollment in
            MarkEntryView(enrollment: enrollment, onSaved: { toast = $0 })
        }
        .toast($toast)
    }

    private func row(for enrollment: Enrollment, showChevron: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(school.subject(withID: enrollment.subjectID)?.title ?? enrollment.subjectID)
                    .font(.body)
                Text(enrollment.academicYear)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(MarkFormat.text(enrollment.mark))
                .font(.body.monospacedDigit())
                .foregroundStyle(enrollment.mark == nil ? .secondary : .primary)
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

enum MarkFormat {
    /// "8.5", "10" or "Not graded".
    static func text(_ mark: Double?) -> String {
        guard let mark else { return "Not graded" }
        return String(format: "%g", mark)
    }
}
