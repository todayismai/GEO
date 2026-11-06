import SwiftUI

/// S05 Teacher List (+ empty state) - UC-03, UC-04.
struct TeacherListView: View {
    @EnvironmentObject private var school: SchoolManager
    @EnvironmentObject private var auth: AuthService
    @State private var showForm = false
    @State private var toast: String?

    private var canAdd: Bool { auth.currentUser?.canManageRecords == true }

    var body: some View {
        Group {
            if school.teachers.isEmpty {
                ContentUnavailableView(
                    "No teachers yet",
                    systemImage: "person.crop.rectangle",
                    description: Text(canAdd ? "Tap + to add the first teacher." : "")
                )
            } else {
                List(school.teachers) { teacher in
                    NavigationLink {
                        TeacherDetailView(teacher: teacher)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(teacher.describe()).font(.body)
                            Text(teacher.email).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Teachers")
        .toolbar {
            if canAdd {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showForm = true
                    } label: {
                        Label("Add Teacher", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showForm) {
            TeacherFormView(onSaved: { toast = $0 })
        }
        .toast($toast)
    }
}
