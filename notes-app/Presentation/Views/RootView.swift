//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import SwiftUI

struct RootView: View {
    // Uygulamanın TEK Auth VM'si burada yaratılıyor
    @State private var authVM = AuthViewModel()

    var body: some View {
        Group {
            if authVM.isAuthenticated {
                NotesListView()
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            Button("Logout") { authVM.logout() }
                        }
                    }
                    .task { await authVM.refreshMe() }
            } else {
                // Aynı VM’yi LoginView’a geçir
                LoginView(authVM: authVM)
            }
        }
        .animation(.default, value: authVM.isAuthenticated)
    }
}
