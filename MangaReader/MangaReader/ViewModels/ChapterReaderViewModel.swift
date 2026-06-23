//
//  ChapterReaderViewModel.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//

import Combine
import Foundation

@MainActor
final class ChapterReaderViewModel: ObservableObject {
    @Published var pages: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 0

    private var baseImageURL = ""

    private let api: APIServiceProtocol

    init(api: APIServiceProtocol = APIService.shared) {
        self.api = api
    }

    func fetchChapterPages(chapterId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let chapterPages = try await api.fetch(.chapterPages(chapterId: chapterId), as: ChapterPages.self)
            baseImageURL = chapterPages.baseUrl
            pages = chapterPages.chapter.data.map { filename in
                "\(chapterPages.baseUrl)/data/\(chapterPages.chapter.hash)/\(filename)"
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadChapter(_ chapterId: String) async {
        // Reset state for a new chapter
        pages = []
        errorMessage = nil
        currentPage = 0
        isLoading = false
        baseImageURL = ""
        await fetchChapterPages(chapterId: chapterId)
    }
}
