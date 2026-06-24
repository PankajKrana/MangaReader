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

    
    @Published private(set) var availableLanguages: [String] = []
    
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


    private func initialLanguage(available: [String], original: String) -> String? {
        if available.contains("en") {
            return "en"
        }
        if available.contains(original) {
            return original
        }
        return available.first
    }
    
    func select(language: String?) async {
        guard language != selectedLanguage else { return }
        selectedLanguage = language
        await loadChapters()
    }

    func loadChapters() async {
        guard let mangaId = mangaId, let language = selectedLanguage else {
            chapters = []
            return
        }

        isLoading = true
        errorMessage = nil
        chapters = []

        let pageSize = 100
        var offset = 0
        var seenIDs = Set<String>()

        do {
            while true {
                let response = try await api.fetch(
                    .chapters(mangaId: mangaId, language: language, limit: pageSize, offset: offset),
                    as: ChapterResponse.self
                )

                let fresh = response.data.filter { seenIDs.insert($0.id).inserted }
                if !fresh.isEmpty {
                    chapters = sortByChapterNumber(chapters + fresh)
                }
                isLoading = false  // first page is enough to start reading

                // Stop when we've collected everything the server reports, or
                // when a page comes back empty (guards against a missing `total`).
                let total = response.total ?? chapters.count
                offset += pageSize
                if response.data.isEmpty || chapters.count >= total { break }
            }
        } catch {
            if chapters.isEmpty { errorMessage = error.localizedDescription }
        }

        isLoading = false
    }

    private func sortByChapterNumber(_ chapters: [Chapter]) -> [Chapter] {
        chapters.sorted { chapter1, chapter2 in
            let num1 = Float(chapter1.attributes.chapter ?? "0") ?? 0
            let num2 = Float(chapter2.attributes.chapter ?? "0") ?? 0
            return num1 < num2
        }
    }
}
