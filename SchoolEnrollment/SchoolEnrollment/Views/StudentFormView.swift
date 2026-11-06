import SwiftUI

/// S03 Student Form (+ S03-E required-field / invalid-email error) - UC-02.
struct StudentFormView: View {
    @EnvironmentObject private var school: SchoolManager
    @Environment(\.dismiss) private var dismiss

    private let editing: Student?
    private let onSaved: (String) -> Void

    @State private var id: String
    @State private var name: String
    @State private var email: String
    @State private var errorMessage: String?

    init(editing: Student? = nil, onSaved: @escaping (String) -> Void = { _ in }) {
        self.editing = editing
        self.onSaved = onSaved
        _id = State(initialValue: editing?.id ?? "")
        _name = State(initialValue: editing?.name ?? "")
        _email = State(initialValue: editing?.email ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Student ID", text: $id)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .disabled(editing != nil)
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                if errorMessage != nil {
                    Section { ErrorBanner(message: errorMessage) }
                }
            }
            .navigationTitle(editing == nil ? "Add Student" : "Edit Student")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }     // returns without saving
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                }
            }
        }
    }

    private func save() {
        do {
            if let editing {
                try school.updateStudent(id: editing.id, name: name, email: email)
                onSaved("Student updated")
            } else {
                let student = try Student(id: id, name: name, email: email)
                try school.addStudent(student)
                onSaved("Student added")
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription   // nothing is saved on failure
        }
    }
}
