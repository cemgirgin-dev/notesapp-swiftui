//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation

protocol AuthRepository {
    func signup(email: String, password: String) async throws
    func login(email: String, password: String) async throws -> String
    func me() async throws -> User
}

final class AuthRepositoryImpl: AuthRepository {
    private let api: APIClient
    init(api: APIClient) { self.api = api }

    // DÜZENLENDİ: signup yanıtını decode ETMİYORUZ; status 2xx ise başarılı say
    func signup(email: String, password: String) async throws {
        struct Body: Encodable { let email: String; let password: String }
        try await api.requestVoid(
            path: "/auth/signup",
            method: "POST",
            body: Body(email: email, password: password)
        )
    }

    func login(email: String, password: String) async throws -> String {
        struct Body: Encodable { let email: String; let password: String }
        let dto: TokenDTO = try await api.request(
            path: "/auth/login",
            method: "POST",
            body: Body(email: email, password: password)
        )
        return dto.access_token
    }

    func me() async throws -> User {
        let dto: UserDTO = try await api.request(path: "/auth/me")
        return dto.toDomain()
    }
}

