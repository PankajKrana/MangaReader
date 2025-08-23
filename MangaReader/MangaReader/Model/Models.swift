//
//  Network.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import Foundation

struct MangaResponse: Codable {
    let data: [MangaData]
}

struct MangaData: Codable, Identifiable {
    let id: String
    let attributes: MangaAttributes
}

struct MangaAttributes: Codable {
    let title: [String: String]
    let status: String?
    let version: Int?
    
    // Convenience: get English title or first available
    var displayTitle: String {
        title["en"] ?? title.values.first ?? "Untitled"
    }
}

struct CoverResponse: Codable {
    let data: [CoverData]
    
    var firstCoverFileName: String? {
        data.first?.attributes.fileName
    }
}

struct CoverData: Codable {
    let attributes: CoverAttributes
    
    func coverURL(for mangaId: String) -> URL? {
        URL(string: "https://uploads.mangadex.org/covers/\(mangaId)/\(attributes.fileName)")
    }
}

struct CoverAttributes: Codable {
    let fileName: String
}
