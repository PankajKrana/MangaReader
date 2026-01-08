//
//  MangaViewModel.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import Combine
import Foundation

class MangaViewModel: ObservableObject {
    @Published var mangas: [MangaWithCover] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "https://api.mangadex.org"
    
    func fetchManga() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/manga?limit=20&includes[]=cover_art&order[followedCount]=desc") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: MangaResponse.self, decoder: JSONDecoder())
            .map { response in
                response.data.map { manga in
                    let coverURL = self.extractCoverURL(from: manga)
                    return MangaWithCover(manga: manga, coverURL: coverURL)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Failed to load manga: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] mangasWithCover in
                    self?.mangas = mangasWithCover
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchMangaSearch(query: String) {
        isLoading = true
        errorMessage = nil
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseURL)/manga?title=\(encodedQuery)&limit=30&includes[]=cover_art&order[relevance]=desc") else {
            errorMessage = "Invalid search URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: MangaResponse.self, decoder: JSONDecoder())
            .map { response in
                response.data.map { manga in
                    let coverURL = self.extractCoverURL(from: manga)
                    return MangaWithCover(manga: manga, coverURL: coverURL)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Search failed: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] mangasWithCover in
                    self?.mangas = mangasWithCover
                }
            )
            .store(in: &cancellables)
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
}
