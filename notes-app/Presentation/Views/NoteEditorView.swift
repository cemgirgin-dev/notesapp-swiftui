//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import SwiftUI

struct NoteEditorView: View {
    var note: Note?
    var onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var content: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextEditor(text: $content)
                    .frame(minHeight: 200)
            }
            .navigationTitle(note == nil ? "New Note" : "Edit Note")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(title, content)
                        dismiss()
                    }.bold()
                }
            }
        }
        .onAppear {
            if let n = note { title = n.title; content = n.content }
        }
    }
}
