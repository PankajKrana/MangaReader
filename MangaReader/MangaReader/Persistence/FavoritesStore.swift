//
//  FavoritesStore.swift
//  MangaReader
//
//

import Foundation
import SwiftData

enum FavoritesStore {
    static func entry(in context: ModelContext, mangaId: String) -> FavoriteManga? {
        let descriptor = FetchDescriptor<FavoriteManga>(
            predicate: #Predicate { $0.mangaId == mangaId }
        )
        return try? context.fetch(descriptor).first
    }

    /// Adds the manga to favorites if absent, removes it if present.
    static func toggle(in context: ModelContext, manga: MangaWithCover) {
        if let existing = entry(in: context, mangaId: manga.manga.id) {
            context.delete(existing)
        } else if let encoded = try? JSONEncoder().encode(manga.manga) {
            context.insert(
                FavoriteManga(
                    mangaId: manga.manga.id,
                    title: manga.displayTitle,
                    coverURLString: manga.coverImageURL?.absoluteString,
                    mangaData: encoded,
                    createdAt: .now
                )
            )
        }
        try? context.save()
    }

    static func remove(in context: ModelContext, mangaId: String) {
        if let existing = entry(in: context, mangaId: mangaId) {
            context.delete(existing)
            try? context.save()
        }
    }
}
