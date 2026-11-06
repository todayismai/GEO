import SwiftUI

/// S00 Login (+ S00-E invalid credentials) - UC-07.
struct LoginView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("Password", text: $password)
                }

                if errorMessage != nil {
                    Section { ErrorBanner(message: errorMessage) }
                }

                Section {
                    Button("Login", action: login)
                        .frame(maxWidth: .infinity)
                }

                Section("Demo accounts") {
                    demoRow("staff", "staff123", "School Staff")
                    demoRow("coordinator", "coord123", "Academic Coordinator")
                    demoRow("teacher", "teacher123", "Teacher")
                }
            }
            .navigationTitle("School Enrollment")
        }
    }

    private func demoRow(_ user: String, _ pass: String, _ role: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(role).font(.subheadline.weight(.medium))
            Text("\(user) / \(pass)").font(.footnote).foregroundStyle(.secondary)
        }
    }

    private func login() {
        do {
            try auth.login(username: username, password: password)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription   // "Incorrect username or password"
        }
    }
}
