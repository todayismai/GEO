import SwiftUI

/// S06 Teacher Form (+ S06-E required-field error) - UC-03.
struct TeacherFormView: View {
    @EnvironmentObject private var school: SchoolManager
    @Environment(\.dismiss) private var dismiss

    private let onSaved: (String) -> Void

    @State private var id = ""
    @State private var name = ""
    @State private var email = ""
    @State private var errorMessage: String?

    init(onSaved: @escaping (String) -> Void = { _ in }) {
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Teacher ID", text: $id)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
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
            .navigationTitle("Add Teacher")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                }
            }
        }
    }

    private func save() {
        do {
            let teacher = try Teacher(id: id, name: name, email: email)
            try school.addTeacher(teacher)
            onSaved("Teacher added")
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
