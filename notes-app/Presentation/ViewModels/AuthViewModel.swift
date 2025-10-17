//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation

@MainActor
@Observable
final class AuthViewModel {
    var email: String = ""
    var password: String = ""
    var isLoading = false
    var error: String? = nil
    var isAuthenticated = (KeychainStore.readToken() != nil)

    private let loginUC: LoginUseCase
    private let signupUC: SignupUseCase
    private let repo: AuthRepository

    // DÜZENLENDİ: default parametre yerine içeride DI çöz
    init(container: AppContainer? = nil) {
        let c = container ?? DI.container
        self.loginUC = LoginUseCaseImpl(repo: c.authRepository)
        self.signupUC = SignupUseCaseImpl(repo: c.authRepository)
        self.repo = c.authRepository
    }

    func login() async {
        guard !email.isEmpty, !password.isEmpty else { return }
        isLoading = true; error = nil
        do {
            let token = try await loginUC.execute(email: email, password: password)
            KeychainStore.saveToken(token)
            isAuthenticated = true
            print("✅ Login successful for \(email). Token saved.")
        } catch {
            self.error = error.localizedDescription
            print("❌ Login error: \(error.localizedDescription)")
        }
        isLoading = false
    }

    // DÜZENLENDİ: Signup başarıysa otomatik login (decode beklemiyor)
    func signup() async {
        guard !email.isEmpty, !password.isEmpty else { return }
        isLoading = true; error = nil
        do {
            try await signupUC.execute(email: email, password: password)
            print("✅ Signup created for \(email). Trying auto-login…")
            let token = try await loginUC.execute(email: email, password: password)
            KeychainStore.saveToken(token)
            isAuthenticated = true
            print("✅ Auto-login successful after signup.")
        } catch {
            self.error = error.localizedDescription
            print("❌ Signup error: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func refreshMe() async {
        do {
            let me = try await repo.me()
            print("ℹ️ /auth/me -> \(me.email)")
        } catch {
            print("⚠️ /auth/me error: \(error.localizedDescription)")
        }
    }

    func logout() {
        KeychainStore.clear()
        isAuthenticated = false
        print("👋 Logged out.")
    }
}

