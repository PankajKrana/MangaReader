//
//  MangaResponse.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//


import Foundation


struct MangaResponse: Codable {
    let result: String
    let response: String
    let data: [MangaData]
    let limit: Int?
    let offset: Int?
    let total: Int?
}

struct MangaData: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: MangaAttributes
    let relationships: [Relationship]?
}

struct MangaAttributes: Codable {
    let title: [String: String]
    let altTitles: [[String: String]]?
    let description: [String: String]
    let isLocked: Bool?
    let links: [String: String]?
    let originalLanguage: String
    let lastVolume: String?
    let lastChapter: String?
    let publicationDemographic: String?
    let status: String
    let year: Int?
    let contentRating: String
    let tags: [Tag]
    let state: String
    let chapterNumbersResetOnNewVolume: Bool
    let createdAt: String
    let updatedAt: String
    let version: Int
    let availableTranslatedLanguages: [String]
    let latestUploadedChapter: String?
    
    // Convenience computed properties
    var displayTitle: String {
        title["en"] ?? title["ja-ro"] ?? title.values.first ?? "Untitled"
    }
    
    var displayDescription: String {
        description["en"] ?? description.values.first ?? "No description available"
    }
    
    var displayStatus: String {
        switch status {
        case "ongoing": return "Ongoing"
        case "completed": return "Completed"
        case "hiatus": return "Hiatus"
        case "cancelled": return "Cancelled"
        default: return status.capitalized
        }
    }
    
    var displayYear: String {
        if let year = year {
            return String(year)
        }
        return "Unknown"
    }
    
    var displayContentRating: String {
        switch contentRating {
        case "safe": return "Safe"
        case "suggestive": return "Suggestive"
        case "erotica": return "Erotica"
        case "pornographic": return "Pornographic"
        default: return contentRating.capitalized
        }
    }
    
    var genreTags: [Tag] {
        tags.filter { tag in
            tag.attributes.group == "genre"
        }
    }
    
    var themeTags: [Tag] {
        tags.filter { tag in
            tag.attributes.group == "theme"
        }
    }
}

struct Tag: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: TagAttributes
}

struct TagAttributes: Codable {
    let name: [String: String]
    let description: [String: String]?
    let group: String
    let version: Int
    
    var displayName: String {
        name["en"] ?? name.values.first ?? "Unknown"
    }
}

struct Relationship: Codable {
    let id: String
    let type: String
    let related: String?
    let attributes: RelationshipAttributes?
}

struct RelationshipAttributes: Codable {
    let fileName: String?
    let description: String?
    let volume: String?
    let locale: String?
    let createdAt: String?
    let updatedAt: String?
    let version: Int?
}

// MARK: - Cover Response Models
struct CoverResponse: Codable {
    let result: String
    let response: String
    let data: [CoverData]
    let limit: Int?
    let offset: Int?
    let total: Int?
}

struct CoverData: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: CoverAttributes
    let relationships: [Relationship]?
}

struct CoverAttributes: Codable {
    let description: String?
    let volume: String?
    let fileName: String
    let locale: String?
    let createdAt: String
    let updatedAt: String
    let version: Int
}

// MARK: - Enhanced Manga with Cover Model
struct MangaWithCover: Identifiable, Hashable {
    var id: String { manga.id }
    let manga: MangaData
    let coverURL: URL?
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(manga.id)
    }
    
    static func == (lhs: MangaWithCover, rhs: MangaWithCover) -> Bool {
        lhs.manga.id == rhs.manga.id
    }
    
    // Convenience computed properties
    var displayTitle: String {
        manga.attributes.displayTitle
    }
    
    var displayDescription: String {
        manga.attributes.displayDescription
    }
    
    var displayStatus: String {
        manga.attributes.displayStatus
    }
    
    var genreTags: [Tag] {
        manga.attributes.genreTags
    }
    
    var coverImageURL: URL? {
        if let coverURL = coverURL {
            return coverURL
        }
        
        // Try to build cover URL from relationships
        if let relationships = manga.relationships {
            for relationship in relationships {
                if relationship.type == "cover_art",
                   let fileName = relationship.attributes?.fileName {
                    let urlString = "https://uploads.mangadex.org/covers/\(manga.id)/\(fileName).256.jpg"
                    return URL(string: urlString)
                }
            }
        }
        
        return nil
    }
}
