//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation

enum AppConstants {
    // Change this to your backend URL (simulator to localhost, device to machine IP)
    static var baseURL = URL(string: "http://127.0.0.1:8000")!

    // App Group for Widget ↔︎ App cache
    static let appGroupId = "group.cemgirgin.notes-app"
    static let widgetCacheKey = "recent_notes_cache"
}
