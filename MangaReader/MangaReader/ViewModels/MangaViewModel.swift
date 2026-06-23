//
//  MangaViewModel.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import Combine
import Foundation

@MainActor
final class MangaViewModel: ObservableObject {
    @Published var mangas: [MangaWithCover] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api: APIServiceProtocol

    init(api: APIServiceProtocol = APIService.shared) {
        self.api = api
    }

    func fetchManga() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await api.fetch(.popularManga, as: MangaResponse.self)
            mangas = response.data.map { manga in
                MangaWithCover(manga: manga, coverURL: extractCoverURL(from: manga))
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func fetchMangaSearch(query: String, filters: MangaSearchFilters) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await api.fetch(.searchManga(query: query), as: MangaResponse.self)
            let mapped = response.data.map { manga in
                MangaWithCover(manga: manga, coverURL: extractCoverURL(from: manga))
            }
            mangas = applyFilters(mapped, filters: filters)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func extractCoverURL(from manga: MangaData) -> URL? {
        guard let relationships = manga.relationships else { return nil }

        for relationship in relationships {
            if relationship.type == "cover_art",
               let fileName = relationship.attributes?.fileName {
                let urlString = "https://uploads.mangadex.org/covers/\(manga.id)/\(fileName).256.jpg"
                return URL(string: urlString)
            }
        }

        return nil
    }

    private func applyFilters(_ items: [MangaWithCover], filters: MangaSearchFilters) -> [MangaWithCover] {
        items.filter { item in
            let statusMatches = filters.status == "any" || item.manga.attributes.status == filters.status

            let yearMatches: Bool = {
                guard filters.year != "any" else { return true }
                guard let itemYear = item.manga.attributes.year else { return false }
                return String(itemYear) == filters.year
            }()

            let genreMatches: Bool = {
                guard filters.genres.isEmpty == false else { return true }
                let itemGenres = Set(item.manga.attributes.tags.map { $0.attributes.displayName.lowercased() })
                return filters.genres.contains { genre in
                    itemGenres.contains(genre.lowercased())
                }
            }()

            return statusMatches && yearMatches && genreMatches
        }
    }
}
