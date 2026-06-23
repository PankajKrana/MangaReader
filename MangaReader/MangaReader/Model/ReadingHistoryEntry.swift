//
//  ReadingHistoryEntry.swift
//  MangaReader
//
//  Persisted reading progress. One entry per manga (keyed on `mangaId`),
//  always reflecting the most recently read chapter and page.
//

import Foundation
import SwiftData

@Model
final class ReadingHistoryEntry {
    /// Manga identity — unique so each manga has a single, latest entry.
    @Attribute(.unique) var mangaId: String
    var mangaTitle: String
    var coverURLString: String?

    var chapterId: String
    var chapterTitle: String

    var currentPage: Int
    var totalPages: Int

    var updatedAt: Date

    init(
        mangaId: String,
        mangaTitle: String,
        coverURLString: String?,
        chapterId: String,
        chapterTitle: String,
        currentPage: Int,
        totalPages: Int,
        updatedAt: Date
    ) {
        self.mangaId = mangaId
        self.mangaTitle = mangaTitle
        self.coverURLString = coverURLString
        self.chapterId = chapterId
        self.chapterTitle = chapterTitle
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.updatedAt = updatedAt
    }

    var coverURL: URL? {
        guard let coverURLString else { return nil }
        return URL(string: coverURLString)
    }
}
