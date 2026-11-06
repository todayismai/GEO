import SwiftUI

/// S08 Subject List: subjects with their teachers. The Academic Coordinator can start an assignment.
struct SubjectListView: View {
    @EnvironmentObject private var school: SchoolManager
    @EnvironmentObject private var auth: AuthService

    @State private var assignSubject: Subject?
    @State private var toast: String?

    private var canAssign: Bool { auth.currentUser?.canAssignSubjects == true }

    var body: some View {
        Group {
            if school.subjects.isEmpty {
                ContentUnavailableView("No subjects yet", systemImage: "books.vertical")
            } else {
                List(school.subjects) { subject in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(subject.describe()).font(.body)
                            Text("Semester \(subject.semester)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(teacherNames(for: subject))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if canAssign {
                            Spacer()
                            Button("Assign") { assignSubject = subject }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                        }
                    }
                }
            }
        }
        .navigationTitle("Subjects")
        .sheet(item: $assignSubject) { subject in
            AssignSubjectView(subjectID: subject.id, onSaved: { toast = $0 })
        }
        .toast($toast)
    }

    private func teacherNames(for subject: Subject) -> String {
        let names = school.teachers(for: subject.id).map(\.name)
        return names.isEmpty ? "No teachers assigned" : "Teachers: " + names.joined(separator: ", ")
    }
}
