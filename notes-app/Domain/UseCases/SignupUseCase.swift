//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation

public protocol SignupUseCase {
    func execute(email: String, password: String) async throws
}
