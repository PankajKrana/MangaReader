//
//  FavoriteManga.swift
//  MangaReader
//
//  A manga the user has favorited. Stores the encoded MangaData so the detail
//  screen can be fully reconstructed without refetching, plus title/cover for
//  cheap grid rendering.
//

import Foundation
import SwiftData

@Model
final class FavoriteManga {
    @Attribute(.unique) var mangaId: String
    var title: String
    var coverURLString: String?
    /// JSON-encoded `MangaData`, used to rebuild a `MangaWithCover` on tap.
    var mangaData: Data
    var createdAt: Date

    init(
        mangaId: String,
        title: String,
        coverURLString: String?,
        mangaData: Data,
        createdAt: Date
    ) {
        self.mangaId = mangaId
        self.title = title
        self.coverURLString = coverURLString
        self.mangaData = mangaData
        self.createdAt = createdAt
    }

    var coverURL: URL? {
        guard let coverURLString else { return nil }
        return URL(string: coverURLString)
    }

    /// Rebuilds the full `MangaWithCover` from the stored data.
    var mangaWithCover: MangaWithCover? {
        guard let data = try? JSONDecoder().decode(MangaData.self, from: mangaData) else {
            return nil
        }
        return MangaWithCover(manga: data, coverURL: coverURL)
    }
}
