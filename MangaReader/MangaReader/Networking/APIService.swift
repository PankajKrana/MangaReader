//
//  APIService.swift
//  MangaReader
//
//

import Foundation


enum APIError: LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed(Error)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            return "No data received"
        }
    }
}

/// The single source of truth for every URL the app talks to.
enum Endpoint {
    case popularManga
    case searchManga(query: String)
    /// Chapter feed for a manga. Pass `language` to filter by a translated
    /// language (e.g. "en"); pass `nil` to fetch chapters in all languages.
    /// `limit`/`offset` drive pagination.
    case chapters(mangaId: String, language: String? = "en", limit: Int = 100, offset: Int = 0)
    case chapterPages(chapterId: String)

    private static let baseURL = "https://api.mangadex.org"

    var url: URL? {
        switch self {
        case .popularManga:
            return URL(string: "\(Endpoint.baseURL)/manga?limit=20&includes[]=cover_art&order[followedCount]=desc")

        case .searchManga(let query):
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return URL(string: "\(Endpoint.baseURL)/manga?title=\(encoded)&limit=30&includes[]=cover_art&order[relevance]=desc")

        case .chapters(let mangaId, let language, let limit, let offset):
            var query = "limit=\(limit)&offset=\(offset)&order[chapter]=asc"
            if let language = language {
                query = "translatedLanguage[]=\(language)&" + query
            }
            return URL(string: "\(Endpoint.baseURL)/manga/\(mangaId)/feed?\(query)")

        case .chapterPages(let chapterId):
            return URL(string: "\(Endpoint.baseURL)/at-home/server/\(chapterId)")
        }
    }
}

// MARK: - Service

protocol APIServiceProtocol {
    func fetch<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
}

final class APIService: APIServiceProtocol {
    static let shared = APIService()

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    /// The one centralized entry point for all data: manga, chapters, pages, etc.
    func fetch<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        let data: Data
        do {
            (data, _) = try await session.data(from: url)
        } catch {
            throw APIError.requestFailed(error)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}
