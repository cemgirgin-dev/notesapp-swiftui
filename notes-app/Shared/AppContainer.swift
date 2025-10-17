//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation

// DI container
final class AppContainer {
    let apiClient: APIClient
    let authRepository: AuthRepository
    let notesRepository: NotesRepository

    init(baseURL: URL) {
        self.apiClient = APIClient(baseURL: baseURL, tokenProvider: { KeychainStore.readToken() })
        self.authRepository = AuthRepositoryImpl(api: apiClient)
        self.notesRepository = NotesRepositoryImpl(api: apiClient)
    }
}

enum DI {
    @MainActor static var container = AppContainer(baseURL: AppConstants.baseURL)
}
