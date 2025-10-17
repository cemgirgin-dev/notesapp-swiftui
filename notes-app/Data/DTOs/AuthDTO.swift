//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//


import Foundation

struct TokenDTO: Codable {
    let access_token: String
    let token_type: String
}

struct UserDTO: Codable {
    let id: Int
    let email: String
    let created_at: Date

    func toDomain() -> User {
        .init(id: id, email: email, createdAt: created_at)
    }
}
