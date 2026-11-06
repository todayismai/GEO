import SwiftUI

@main
struct SchoolEnrollmentApp: App {
    @StateObject private var school = SchoolManager.seeded()
    @StateObject private var auth = AuthService(accounts: UserAccount.demoAccounts)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(school)
                .environmentObject(auth)
        }
    }
}

/// Shows S00 Login until someone is signed in, then S04 Home.
struct RootView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        if auth.currentUser == nil {
            LoginView()
        } else {
            HomeView()
        }
    }
}
