//
//  MangaDetailViewModel.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//

import Foundation
import Combine

@MainActor
final class MangaDetailViewModel: ObservableObject {
    @Published var chapters: [Chapter] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURL = "https://api.mangadex.org"

    func fetchChapters(for mangaId: String) async {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "\(baseURL)/manga/\(mangaId)/feed?translatedLanguage[]=en&limit=100&order[chapter]=asc") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let chapterResponse = try JSONDecoder().decode(ChapterResponse.self, from: data)
            chapters = chapterResponse.data.sorted { chapter1, chapter2 in
                let num1 = Float(chapter1.attributes.chapter ?? "0") ?? 0
                let num2 = Float(chapter2.attributes.chapter ?? "0") ?? 0
                return num1 < num2
            }
        } catch {
            errorMessage = "Failed to load chapters: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
