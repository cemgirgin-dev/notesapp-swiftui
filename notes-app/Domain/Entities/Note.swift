//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation

public struct Note: Identifiable, Hashable, Codable {
    public let id: Int
    public var title: String
    public var content: String
    public let createdAt: Date
    public let updatedAt: Date
}
