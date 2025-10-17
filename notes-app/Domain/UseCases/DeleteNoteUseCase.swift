//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation

public protocol DeleteNoteUseCase {
    func execute(id: Int) async throws
}
