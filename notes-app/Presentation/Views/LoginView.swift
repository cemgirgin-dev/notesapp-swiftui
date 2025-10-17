//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import SwiftUI
import Observation

struct LoginView: View {
    // RootView’dan gelen TEK ortak VM
    @Bindable var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Notes").font(.largeTitle).bold()

            TextField("Email", text: $authVM.email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $authVM.password)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button(authVM.isLoading ? "Signing up..." : "Sign Up") {
                    Task { await authVM.signup() }
                }
                .buttonStyle(.bordered)
                .disabled(authVM.isLoading)

                Button(authVM.isLoading ? "Signing in..." : "Sign In") {
                    Task { await authVM.login() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(authVM.isLoading)
            }

            if let error = authVM.error {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
        .padding()
    }
}
