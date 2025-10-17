//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

struct WidgetCache: Codable {
    var recentNotes: [Note]
}

enum WidgetCacheStore {
    static func save(_ cache: WidgetCache) {
        guard let ud = UserDefaults(suiteName: AppConstants.appGroupId) else { return }
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        if let data = try? enc.encode(cache) {
            ud.set(data, forKey: AppConstants.widgetCacheKey)
        }
        // 🔁 Cache yazılır yazılmaz timeline'ı yenile
        #if canImport(WidgetKit)
        // Widget struct'ındaki kind ile birebir aynı olmalı:
        WidgetCenter.shared.reloadTimelines(ofKind: "NotesWidget")
        #endif
    }

    static func load() -> WidgetCache {
        guard let ud = UserDefaults(suiteName: AppConstants.appGroupId),
              let data = ud.data(forKey: AppConstants.widgetCacheKey) else {
            return .init(recentNotes: [])
        }
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return (try? dec.decode(WidgetCache.self, from: data)) ?? .init(recentNotes: [])
    }
}

