//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation

public struct User: Codable, Hashable {
    public let id: Int
    public let email: String
    public let createdAt: Date
}
