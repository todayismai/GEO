import SwiftUI

/// S07 Teacher Detail: subjects assigned to a teacher. The Academic Coordinator can assign/remove (UC-04).
struct TeacherDetailView: View {
    @EnvironmentObject private var school: SchoolManager
    @EnvironmentObject private var auth: AuthService

    let teacher: Teacher

    @State private var showAssign = false
    @State private var toast: String?

    private var canAssign: Bool { auth.currentUser?.canAssignSubjects == true }

    var body: some View {
        List {
            Section("Teacher") {
                LabeledContent("ID", value: teacher.id)
                LabeledContent("Name", value: teacher.name)
                LabeledContent("Email", value: teacher.email)
            }

            Section("Assigned subjects") {
                let assigned = school.subjects(for: teacher.id)
                if assigned.isEmpty {
                    Text("No subjects assigned yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(assigned) { subject in
                        Text(subject.describe())
                    }
                    .onDelete(perform: canAssign ? { offsets in
                        for index in offsets {
                            school.unassign(subjectID: assigned[index].id, fromTeacherID: teacher.id)
                        }
                    } : nil)
                }
            }

            if canAssign {
                Section {
                    Button {
                        showAssign = true
                    } label: {
                        Label("Assign subject", systemImage: "link.badge.plus")
                    }
                    Text("Swipe a subject to remove it.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(teacher.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAssign) {
            AssignSubjectView(teacherID: teacher.id, onSaved: { toast = $0 })
        }
        .toast($toast)
    }
}
