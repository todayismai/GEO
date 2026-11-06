import SwiftUI

/// S04 Home. Shows only the actions allowed for the signed-in role.
struct HomeView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var showEnroll = false
    @State private var toast: String?

    var body: some View {
        NavigationStack {
            List {
                if let user = auth.currentUser {
                    Section("Signed in") {
                        Label(user.username, systemImage: "person.circle")
                        Text(user.roleTitle).foregroundStyle(.secondary)
                    }

                    Section("Records") {
                        NavigationLink {
                            StudentListView()
                        } label: {
                            Label("Students", systemImage: "person.3")
                        }

                        if user.canManageRecords {
                            NavigationLink {
                                TeacherListView()
                            } label: {
                                Label("Teachers", systemImage: "person.crop.rectangle")
                            }
                            NavigationLink {
                                SubjectListView()
                            } label: {
                                Label("Subjects", systemImage: "books.vertical")
                            }
                        }
                    }

                    if user.canEnroll {
                        Section("Actions") {
                            Button {
                                showEnroll = true
                            } label: {
                                Label("Enroll Student", systemImage: "plus.circle")
                            }
                        }
                    }

                    if user.canEnterMarks {
                        Section {
                            Text("To enter or update a mark, open Students, choose a student, then tap an enrollment.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("School Enrollment")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Log out") { auth.logout() }
                }
            }
            .sheet(isPresented: $showEnroll) {
                EnrollmentView(onSaved: { toast = $0 })
            }
            .toast($toast)
        }
    }
}
