//
//  Chapter.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//


import Foundation


struct Chapter: Identifiable, Codable {
    let id: String
    let type: String
    let attributes: ChapterAttributes
    
    struct ChapterAttributes: Codable {
        let volume: String?
        let chapter: String?
        let title: String?
        let translatedLanguage: String
        let externalUrl: String?
        let publishAt: String
        let readableAt: String
        let createdAt: String
        let updatedAt: String
        let pages: Int
        let version: Int
    }
    
    var displayTitle: String {
        var title = ""
        if let volume = attributes.volume {
            title += "Vol. \(volume) "
        }
        if let chapter = attributes.chapter {
            title += "Ch. \(chapter)"
        }
        if let chapterTitle = attributes.title, !chapterTitle.isEmpty {
            title += " - \(chapterTitle)"
        }
        return title.isEmpty ? "Chapter \(id.prefix(8))" : title
    }
}

// Hashable by id so chapters can drive value-based navigation.
extension Chapter: Hashable {
    static func == (lhs: Chapter, rhs: Chapter) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Chapter Response Model
struct ChapterResponse: Codable {
    let result: String
    let response: String
    let data: [Chapter]
    // Pagination metadata returned by the /manga/{id}/feed endpoint.
    // Optional so older/partial payloads still decode.
    let limit: Int?
    let offset: Int?
    let total: Int?
}

// MARK: - Chapter Pages Model
struct ChapterPages: Codable {
    let result: String
    let baseUrl: String
    let chapter: ChapterPagesData
    
    struct ChapterPagesData: Codable {
        let hash: String
        let data: [String]
        let dataSaver: [String]
    }
}
