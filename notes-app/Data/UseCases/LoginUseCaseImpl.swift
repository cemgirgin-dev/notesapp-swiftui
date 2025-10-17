//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation

final class LoginUseCaseImpl: LoginUseCase {
    private let repo: AuthRepository
    init(repo: AuthRepository) { self.repo = repo }

    func execute(email: String, password: String) async throws -> String {
        try await repo.login(email: email, password: password)
    }
}
