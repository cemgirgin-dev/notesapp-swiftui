//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

@main
struct NotesCleanApp: App {
    @Environment(\.scenePhase) private var scenePhase

    init() {
        _ = DI.container
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .onChange(of: scenePhase) { _, newPhase in
            #if canImport(WidgetKit)
            if newPhase == .active {
                WidgetCenter.shared.reloadAllTimelines()
            }
            #endif
        }
    }
}

