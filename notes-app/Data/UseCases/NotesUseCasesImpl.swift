//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation

final class FetchNotesUseCaseImpl: FetchNotesUseCase {
    private let repo: NotesRepository
    init(repo: NotesRepository) { self.repo = repo }

    func execute() async throws -> [Note] { try await repo.fetchNotes() }
}

final class CreateNoteUseCaseImpl: CreateNoteUseCase {
    private let repo: NotesRepository
    init(repo: NotesRepository) { self.repo = repo }

    func execute(title: String, content: String) async throws -> Note {
        try await repo.create(title: title, content: content)
    }
}

final class UpdateNoteUseCaseImpl: UpdateNoteUseCase {
    private let repo: NotesRepository
    init(repo: NotesRepository) { self.repo = repo }

    func execute(id: Int, title: String?, content: String?) async throws -> Note {
        try await repo.update(id: id, title: title, content: content)
    }
}

final class DeleteNoteUseCaseImpl: DeleteNoteUseCase {
    private let repo: NotesRepository
    init(repo: NotesRepository) { self.repo = repo }

    func execute(id: Int) async throws { try await repo.delete(id: id) }
}
