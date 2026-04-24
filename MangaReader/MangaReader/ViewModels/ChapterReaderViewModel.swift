//
//  ChapterReaderViewModel.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//

import Foundation
import Combine

@MainActor
final class ChapterReaderViewModel: ObservableObject {
    @Published var pages: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 0

    private let baseURL = "https://api.mangadex.org"

    func fetchChapterPages(chapterId: String) async {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "\(baseURL)/at-home/server/\(chapterId)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let chapterPages = try JSONDecoder().decode(ChapterPages.self, from: data)
            pages = chapterPages.chapter.data.map { filename in
                "\(chapterPages.baseUrl)/data/\(chapterPages.chapter.hash)/\(filename)"
            }
        } catch {
            errorMessage = "Failed to decode pages: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func loadChapter(_ chapterId: String) async {
        pages = []
        errorMessage = nil
        currentPage = 0
        isLoading = false
        await fetchChapterPages(chapterId: chapterId)
    }
}
