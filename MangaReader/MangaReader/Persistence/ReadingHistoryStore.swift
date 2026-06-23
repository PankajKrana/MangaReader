//
//  ReadingHistoryStore.swift
//  MangaReader
//
//  Thin helper for reading/writing ReadingHistoryEntry. Keeps SwiftData write
//  logic out of the Views without introducing a singleton or repository layer.
//

import Foundation
import SwiftData

enum ReadingHistoryStore {
    /// Inserts or updates the entry for a manga with the latest read position.
    static func record(
        in context: ModelContext,
        mangaId: String,
        mangaTitle: String,
        coverURLString: String?,
        chapterId: String,
        chapterTitle: String,
        currentPage: Int,
        totalPages: Int,
        date: Date = .now
    ) {
        if let existing = entry(in: context, mangaId: mangaId) {
            existing.mangaTitle = mangaTitle
            existing.coverURLString = coverURLString
            existing.chapterId = chapterId
            existing.chapterTitle = chapterTitle
            existing.currentPage = currentPage
            existing.totalPages = totalPages
            existing.updatedAt = date
        } else {
            context.insert(
                ReadingHistoryEntry(
                    mangaId: mangaId,
                    mangaTitle: mangaTitle,
                    coverURLString: coverURLString,
                    chapterId: chapterId,
                    chapterTitle: chapterTitle,
                    currentPage: currentPage,
                    totalPages: totalPages,
                    updatedAt: date
                )
            )
        }

        try? context.save()
    }

    /// Returns the stored entry for a manga, if any.
    static func entry(in context: ModelContext, mangaId: String) -> ReadingHistoryEntry? {
        let descriptor = FetchDescriptor<ReadingHistoryEntry>(
            predicate: #Predicate { $0.mangaId == mangaId }
        )
        return try? context.fetch(descriptor).first
    }
}
