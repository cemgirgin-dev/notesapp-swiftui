//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import SwiftUI

struct NotesListView: View {
    @Environment(\.openURL) private var openURL
    @State private var vm = NotesViewModel()
    @State private var showEditor = false
    @State private var selected: Note? = nil
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading notes...")
                } else if !filtered.isEmpty {
                    List {
                        ForEach(filtered) { note in
                            Button {
                                selected = note
                                showEditor = true
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(note.title).font(.headline)
                                    Text(note.content).lineLimit(2).font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions {
                                Button("Export PDF") {
                                    openURL(vm.exportPDFURL(for: note))
                                }
                                Button(role: .destructive) {
                                    Task { await vm.delete(note: note) }
                                } label: { Text("Delete") }
                            }
                        }
                    }
                } else {
                    ContentUnavailableView("No Notes", systemImage: "note.text",
                                           description: Text("Create your first note"))
                }
            }
            .navigationTitle("Your Notes")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reload") { Task { await vm.load() } }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selected = nil
                        showEditor = true
                    } label: { Image(systemName: "plus") }
                }
            }
            .searchable(text: $searchText)
            .task { await vm.load() }
            .sheet(isPresented: $showEditor) {
                NoteEditorView(note: selected) { title, content in
                    if let n = selected {
                        Task { await vm.update(note: n, title: title, content: content) }
                    } else {
                        Task { await vm.create(title: title, content: content) }
                    }
                }
                .presentationDetents([.medium, .large])
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    Task { await vm.load() }
                } label: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 44))
                        .padding()
                }
            }
            .padding(.bottom, 4)
        }
    }

    var filtered: [Note] {
        guard !searchText.isEmpty else { return vm.notes }
        return vm.notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.content.localizedCaseInsensitiveContains(searchText) }
    }
}
