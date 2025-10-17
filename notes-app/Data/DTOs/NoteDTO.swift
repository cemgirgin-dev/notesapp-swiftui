//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//


import Foundation

struct NoteDTO: Codable {
    let id: Int
    let title: String
    let content: String
    let created_at: Date
    let updated_at: Date

    func toDomain() -> Note {
        .init(id: id, title: title, content: content, createdAt: created_at, updatedAt: updated_at)
    }
}

struct NoteCreateDTO: Codable {
    let title: String
    let content: String
}

struct NoteUpdateDTO: Codable {
    let title: String?
    let content: String?
}
