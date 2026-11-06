import SwiftUI

/// S09 Assign Subject to Teacher (+ S09-E nothing selected) - UC-04.
struct AssignSubjectView: View {
    @EnvironmentObject private var school: SchoolManager
    @Environment(\.dismiss) private var dismiss

    private let onSaved: (String) -> Void

    @State private var teacherID: String?
    @State private var selected: Set<String>
    @State private var errorMessage: String?

    init(teacherID: String? = nil, subjectID: String? = nil, onSaved: @escaping (String) -> Void = { _ in }) {
        self.onSaved = onSaved
        _teacherID = State(initialValue: teacherID)
        _selected = State(initialValue: subjectID.map { Set([$0]) } ?? Set<String>())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Teacher") {
                    Picker("Teacher", selection: $teacherID) {
                        Text("Select…").tag(String?.none)
                        ForEach(school.teachers) { teacher in
                            Text(teacher.describe()).tag(Optional(teacher.id))
                        }
                    }
                }

                Section("Subjects") {
                    ForEach(school.subjects) { subject in
                        Button {
                            toggle(subject.id)
                        } label: {
                            HStack {
                                Text(subject.describe())
                                Spacer()
                                if selected.contains(subject.id) {
                                    Image(systemName: "checkmark").foregroundStyle(.tint)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }

                if errorMessage != nil {
                    Section { ErrorBanner(message: errorMessage) }
                }
            }
            .navigationTitle("Assign Subject")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }      // nothing saved
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm", action: confirm)
                }
            }
        }
    }

    private func toggle(_ id: String) {
        if selected.contains(id) {
            selected.remove(id)
        } else {
            selected.insert(id)
        }
    }

    private func confirm() {
        do {
            guard let chosenTeacher = teacherID, !selected.isEmpty else {
                throw ValidationError.emptyField("Select a teacher and at least one subject")
            }
            for subjectID in selected.sorted() {
                try school.assign(subjectID: subjectID, toTeacherID: chosenTeacher)
            }
            onSaved("Subject assigned")
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
