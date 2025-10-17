//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation

public protocol NotesRepository {
    func fetchNotes() async throws -> [Note]
    func create(title: String, content: String) async throws -> Note
    func update(id: Int, title: String?, content: String?) async throws -> Note
    func delete(id: Int) async throws
    func pdfURL(for id: Int) -> URL
    func exportPDFFile(id: Int) async throws -> URL   // 🔽 YENİ
}

final class NotesRepositoryImpl: NotesRepository {
    private let api: APIClient
    init(api: APIClient) { self.api = api }

    func fetchNotes() async throws -> [Note] {
        let list: [NoteDTO] = try await api.request(path: "/notes/")
        return list.map { $0.toDomain() }
    }

    func create(title: String, content: String) async throws -> Note {
        let body = NoteCreateDTO(title: title, content: content)
        let dto: NoteDTO = try await api.request(path: "/notes/", method: "POST", body: body)
        return dto.toDomain()
    }

    func update(id: Int, title: String?, content: String?) async throws -> Note {
        let body = NoteUpdateDTO(title: title, content: content)
        let dto: NoteDTO = try await api.request(path: "/notes/\(id)/", method: "PUT", body: body)
        return dto.toDomain()
    }

    func delete(id: Int) async throws {
        try await api.requestVoid(path: "/notes/\(id)/", method: "DELETE")
    }

    func pdfURL(for id: Int) -> URL {
        AppConstants.baseURL.appendingPathComponent("/notes/\(id)/export/pdf")
    }

    // 🔽 YENİ: PDF indir → temp'e yaz → URL döndür
    func exportPDFFile(id: Int) async throws -> URL {
        let data = try await api.requestData(path: "/notes/\(id)/export/pdf")
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("note-\(id)-\(UUID().uuidString)")
            .appendingPathExtension("pdf")
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }
}



