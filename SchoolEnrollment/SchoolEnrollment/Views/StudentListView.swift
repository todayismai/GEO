import SwiftUI

/// S01 Student List (+ S01-E empty state) - UC-01.
struct StudentListView: View {
    @EnvironmentObject private var school: SchoolManager
    @EnvironmentObject private var auth: AuthService
    @State private var search = ""
    @State private var showForm = false
    @State private var toast: String?

    private var canAdd: Bool { auth.currentUser?.canManageRecords == true }

    private var filtered: [Student] {
        let query = search.trimmed
        guard !query.isEmpty else { return school.students }
        return school.students.filter {
            $0.id.localizedCaseInsensitiveContains(query) || $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        Group {
            if school.students.isEmpty {
                ContentUnavailableView(
                    "No students yet",
                    systemImage: "person.3",
                    description: Text(canAdd ? "Tap + to add the first student." : "")
                )
            } else if filtered.isEmpty {
                ContentUnavailableView.search(text: search)
            } else {
                List(filtered) { student in
                    NavigationLink {
                        StudentDetailView(student: student)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(student.describe()).font(.body)
                            Text(student.email).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Students")
        .searchable(text: $search, prompt: "Search by ID or name")
        .toolbar {
            if canAdd {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showForm = true
                    } label: {
                        Label("Add Student", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showForm) {
            StudentFormView(onSaved: { toast = $0 })
        }
        .toast($toast)
    }
}
