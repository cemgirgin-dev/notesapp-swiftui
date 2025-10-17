//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation

public protocol UpdateNoteUseCase {
    func execute(id: Int, title: String?, content: String?) async throws -> Note
}
