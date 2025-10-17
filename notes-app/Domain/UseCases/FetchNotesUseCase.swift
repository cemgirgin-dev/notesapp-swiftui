//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation

public protocol FetchNotesUseCase {
    func execute() async throws -> [Note]
}
