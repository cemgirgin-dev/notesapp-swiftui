//
//  notes_appApp.swift
//  notes-app
//
//  Created by Cem Girgin on 17.10.25.
//

import Foundation
import Observation  // @Observable için

@MainActor
@Observable
final class NotesViewModel {
    var notes: [Note] = []
    var isLoading = false
    var error: String? = nil
    var query: String = ""

    private let fetchUC: FetchNotesUseCase
    private let createUC: CreateNoteUseCase
    private let updateUC: UpdateNoteUseCase
    private let deleteUC: DeleteNoteUseCase
    private let notesRepo: NotesRepository

    init(container: AppContainer? = nil) {
        let c = container ?? DI.container
        self.fetchUC  = FetchNotesUseCaseImpl(repo: c.notesRepository)
        self.createUC = CreateNoteUseCaseImpl(repo: c.notesRepository)
        self.updateUC = UpdateNoteUseCaseImpl(repo: c.notesRepository)
        self.deleteUC = DeleteNoteUseCaseImpl(repo: c.notesRepository)
        self.notesRepo = c.notesRepository
    }

    func load() async {
        isLoading = true; error = nil
        do {
            notes = try await fetchUC.execute()
            updateWidgetCache()
        } catch { errorLog(error) }
        isLoading = false
    }

    func create(title: String, content: String) async {
        do {
            let note = try await createUC.execute(title: title, content: content)
            notes.insert(note, at: 0)
            updateWidgetCache()
        } catch { errorLog(error) }
    }

    func update(note: Note, title: String?, content: String?) async {
        do {
            let updated = try await updateUC.execute(id: note.id, title: title, content: content)
            if let idx = notes.firstIndex(where: { $0.id == note.id }) { notes[idx] = updated }
            updateWidgetCache()
        } catch { errorLog(error) }
    }

    func delete(note: Note) async {
        do {
            try await deleteUC.execute(id: note.id)
            notes.removeAll { $0.id == note.id }
            updateWidgetCache()
        } catch { errorLog(error) }
    }

    func exportPDFURL(for note: Note) -> URL { notesRepo.pdfURL(for: note.id) }

    // 🔽 YENİ: PDF dosyasını indirip paylaşım/önizleme için dosya URL’i döndür
    func downloadPDF(for note: Note) async -> URL? {
        do { return try await notesRepo.exportPDFFile(id: note.id) }
        catch { errorLog(error); return nil }
    }

    private func updateWidgetCache() {
        let top = Array(notes.prefix(5))
        WidgetCacheStore.save(.init(recentNotes: top))
    }

    private func errorLog(_ error: Error) {
        self.error = error.localizedDescription
        print("❌ NotesViewModel error: \(error.localizedDescription)")
    }
}


