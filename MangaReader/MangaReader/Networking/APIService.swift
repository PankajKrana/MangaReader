//
//  APIService.swift
//  MangaReader
//
//

import Foundation


enum APIError: LocalizedError, Equatable {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed(Error)
    case noData

    // HTTP status-based errors
    case badRequest                       // 400
    case unauthorized                     // 401
    case forbidden                        // 403
    case notFound                         // 404
    case rateLimited(retryAfter: TimeInterval?)  // 429
    case serverError                      // 500
    case serviceUnavailable               // 503
    case unexpectedStatus(Int)            // any other non-2xx

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
        case .badRequest:
            return "The request was invalid. Please try again."
        case .unauthorized:
            return "You are not authorized to access this content."
        case .forbidden:
            return "Access to this content is forbidden."
        case .notFound:
            return "The requested content could not be found."
        case .rateLimited:
            return "Too many requests. Please slow down and try again in a moment."
        case .serverError:
            return "The server encountered an error. Please try again later."
        case .serviceUnavailable:
            return "The service is temporarily unavailable. Please try again later."
        case .unexpectedStatus(let code):
            return "Unexpected server response (status code \(code))."
        }
    }

    // Equatable: compare by case (associated Errors aren't Equatable, so
    // requestFailed/decodingFailed match on case only). Useful for tests.
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.requestFailed, .requestFailed),
             (.decodingFailed, .decodingFailed),
             (.noData, .noData),
             (.badRequest, .badRequest),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound),
             (.serverError, .serverError),
             (.serviceUnavailable, .serviceUnavailable):
            return true
        case let (.rateLimited(a), .rateLimited(b)):
            return a == b
        case let (.unexpectedStatus(a), .unexpectedStatus(b)):
            return a == b
        default:
            return false
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

    /// Default session with sensible timeouts so requests don't hang forever.
    private static func defaultSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15   // per-request
        config.timeoutIntervalForResource = 30  // whole resource load
        return URLSession(configuration: config)
    }

    init(session: URLSession? = nil, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session ?? APIService.defaultSession()
        self.decoder = decoder
    }

    /// The one centralized entry point for all data: manga, chapters, pages, etc.
    /// Validates the HTTP status code before decoding and retries once on 429.
    func fetch<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        do {
            let data = try await requestData(from: url)
            return try decode(data, as: T.self)
        } catch APIError.rateLimited(let retryAfter) {
            // Retry exactly once for 429, honoring Retry-After when present.
            let delay = retryAfter ?? 1
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            let data = try await requestData(from: url)
            return try decode(data, as: T.self)
        }
    }

    /// Performs the network request and validates the HTTP status code.
    /// HTTP errors are mapped to `APIError` cases and never reach the decoder.
    private func requestData(from url: URL) async throws -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw APIError.requestFailed(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.noData
        }

        switch http.statusCode {
        case 200..<300:
            return data
        case 400:
            throw APIError.badRequest
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 429:
            throw APIError.rateLimited(retryAfter: Self.retryAfterSeconds(from: http))
        case 500:
            throw APIError.serverError
        case 503:
            throw APIError.serviceUnavailable
        default:
            throw APIError.unexpectedStatus(http.statusCode)
        }
    }

    private func decode<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    /// Parses the `Retry-After` header (delay in seconds) if present.
    private static func retryAfterSeconds(from response: HTTPURLResponse) -> TimeInterval? {
        guard let value = response.value(forHTTPHeaderField: "Retry-After"),
              let seconds = TimeInterval(value.trimmingCharacters(in: .whitespaces)) else {
            return nil
        }
        return seconds
    }
}
