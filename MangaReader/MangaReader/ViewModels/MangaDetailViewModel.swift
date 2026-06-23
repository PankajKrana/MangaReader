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

    private let api: APIServiceProtocol

    init(api: APIServiceProtocol = APIService.shared) {
        self.api = api
    }

    /// The language requested first. Falls back to all languages when empty.
    private let preferredLanguage = "en"

    func fetchChapters(for mangaId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            // English first.
            var result = try await fetchAllChapters(mangaId: mangaId, language: preferredLanguage)

            // Fallback: if the preferred language has no chapters, retry
            // without any language filter so manga translated only into
            // other languages still show their chapters.
            if result.isEmpty {
                result = try await fetchAllChapters(mangaId: mangaId, language: nil)
            }

            chapters = sortByChapterNumber(result)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Fetches every chapter for a manga by walking the API's pagination
    /// (`total`/`offset`/`limit`) until all pages are retrieved. Pages are
    /// requested sequentially and concatenated in order; duplicate chapter IDs
    /// are skipped as a safety net.
    private func fetchAllChapters(mangaId: String, language: String?) async throws -> [Chapter] {
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
