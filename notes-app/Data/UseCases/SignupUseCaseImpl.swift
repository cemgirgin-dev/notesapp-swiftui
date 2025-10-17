//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation

final class SignupUseCaseImpl: SignupUseCase {
    private let repo: AuthRepository
    init(repo: AuthRepository) { self.repo = repo }

    func execute(email: String, password: String) async throws {
        try await repo.signup(email: email, password: password)
    }
}
