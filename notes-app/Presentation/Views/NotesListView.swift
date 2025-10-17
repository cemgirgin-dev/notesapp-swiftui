//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import SwiftUI
import QuickLook

// Share Sheet köprüsü
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

// Quick Look köprüsü (PDF önizleme)
struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let c = QLPreviewController()
        c.dataSource = context.coordinator
        return c
    }
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(url: url) }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        init(url: URL) { self.url = url }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}

struct NotesListView: View {
    @Environment(\.openURL) private var openURL
    @State private var vm = NotesViewModel()
    @State private var showEditor = false
    @State private var selected: Note? = nil
    @State private var searchText = ""

    // Paylaşım & Önizleme state
    @State private var shareURL: URL? = nil
    @State private var showShare = false
    @State private var previewURL: URL? = nil
    @State private var showPreview = false

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading notes...")
                } else if !filtered.isEmpty {
                    List {
                        ForEach(filtered) { note in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(note.title).font(.headline)
                                    Text(note.content).lineLimit(2).font(.subheadline).foregroundStyle(.secondary)
                                }
                                Spacer()

                                // Paylaş (PDF indir + Share Sheet)
                                Button {
                                    Task {
                                        if let url = await vm.downloadPDF(for: note) {
                                            shareURL = url
                                            showShare = true
                                        }
                                    }
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                                .buttonStyle(.borderless)
                                .help("PDF olarak paylaş")

                                // Önizleme (PDF indir + Quick Look)
                                Button {
                                    Task {
                                        if let url = await vm.downloadPDF(for: note) {
                                            previewURL = url
                                            showPreview = true
                                        }
                                    }
                                } label: {
                                    Image(systemName: "eye")
                                }
                                .buttonStyle(.borderless)
                                .help("PDF'i önizle")
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selected = note
                                showEditor = true
                            }
                            .swipeActions {
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
            // Share Sheet
            .sheet(isPresented: $showShare, onDismiss: { shareURL = nil }) {
                if let shareURL {
                    ShareSheet(activityItems: [shareURL]).ignoresSafeArea()
                } else {
                    Text("Preparing PDF…").padding()
                }
            }
            // Quick Look
            .sheet(isPresented: $showPreview, onDismiss: { previewURL = nil }) {
                if let previewURL {
                    QuickLookPreview(url: previewURL).ignoresSafeArea()
                } else {
                    Text("Preparing preview…").padding()
                }
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
        return vm.notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// İsteğe bağlı Preview
#Preview("NotesListView – Light") {
    NotesListView()
        .preferredColorScheme(.light)
}
#Preview("NotesListView – Dark") {
    NotesListView()
        .preferredColorScheme(.dark)
        .environment(\.locale, .init(identifier: "tr_TR"))
}

