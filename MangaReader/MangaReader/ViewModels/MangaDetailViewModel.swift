//
//  MangaDetailViewModel.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//

import Combine
import Foundation

@MainActor
final class MangaDetailViewModel: ObservableObject {
    @Published var chapters: [Chapter] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// Languages this manga is translated into, as provided by MangaDex.
    @Published private(set) var availableLanguages: [String] = []
    /// The language currently shown. Changing it reloads the chapter list.
    @Published var selectedLanguage: String?

    private let api: APIServiceProtocol
    private var mangaId: String?

    init(api: APIServiceProtocol = APIService.shared) {
        self.api = api
    }

    /// Entry point from the view. Sets up the available languages, chooses the
    /// most appropriate initial language (see `initialLanguage`), and loads
    /// chapters for it. Does nothing chapter-wise when no languages exist —
    /// the view then shows the "No chapters available" empty state.
    func start(mangaId: String, availableLanguages: [String], originalLanguage: String) async {
        self.mangaId = mangaId
        self.availableLanguages = availableLanguages
        self.selectedLanguage = initialLanguage(
            available: availableLanguages,
            original: originalLanguage
        )

        await loadChapters()
    }

    /// Picks the initial language by priority:
    /// 1. English, if available.
    /// 2. The manga's original language, but only if it is actually available.
    /// 3. The first available language.
    /// 4. `nil` when nothing is available (empty-state behavior).
    private func initialLanguage(available: [String], original: String) -> String? {
        if available.contains("en") {
            return "en"
        }
        if available.contains(original) {
            return original
        }
        return available.first
    }

    /// Called by the picker when the user chooses a language. Ignores no-op
    /// selections so we never fire a duplicate request for the language that
    /// is already showing.
    func select(language: String?) async {
        guard language != selectedLanguage else { return }
        selectedLanguage = language
        await loadChapters()
    }

    /// Reloads the chapter list for the currently selected language.
    func loadChapters() async {
        guard let mangaId = mangaId, let language = selectedLanguage else {
            chapters = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await fetchAllChapters(mangaId: mangaId, language: language)
            chapters = sortByChapterNumber(result)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Fetches every chapter for a manga in a given language by walking the
    /// API's pagination (`total`/`offset`/`limit`) until all pages are
    /// retrieved. Pages are requested sequentially and concatenated in order;
    /// duplicate chapter IDs are skipped as a safety net.
    private func fetchAllChapters(mangaId: String, language: String) async throws -> [Chapter] {
        let pageSize = 100
        var offset = 0
        var collected: [Chapter] = []
        var seenIDs = Set<String>()

        while true {
            let response = try await api.fetch(
                .chapters(mangaId: mangaId, language: language, limit: pageSize, offset: offset),
                as: ChapterResponse.self
            )

            for chapter in response.data where !seenIDs.contains(chapter.id) {
                seenIDs.insert(chapter.id)
                collected.append(chapter)
            }

            // Stop when we've collected everything the server reports, or when
            // a page comes back empty (guards against a missing `total`).
            let total = response.total ?? collected.count
            offset += pageSize
            if response.data.isEmpty || collected.count >= total {
                break
            }
        }

        return collected
    }

    private func sortByChapterNumber(_ chapters: [Chapter]) -> [Chapter] {
        chapters.sorted { chapter1, chapter2 in
            let num1 = Float(chapter1.attributes.chapter ?? "0") ?? 0
            let num2 = Float(chapter2.attributes.chapter ?? "0") ?? 0
            return num1 < num2
        }
    }
}
