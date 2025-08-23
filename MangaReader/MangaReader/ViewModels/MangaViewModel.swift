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
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchManga() {
        isLoading = true
        guard let url = URL(string: "https://api.mangadex.org/manga?limit=10") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: MangaResponse.self, decoder: JSONDecoder())
            .flatMap { response -> AnyPublisher<[MangaWithCover], Never> in
                let publishers = response.data.map { manga in
                    self.fetchCover(for: manga)
                }
                return Publishers.MergeMany(publishers)
                    .collect()
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.isLoading = false
            } receiveValue: { mangasWithCover in
                self.mangas = mangasWithCover
            }
            .store(in: &cancellables)
    }
    
    private func fetchCover(for manga: MangaData) -> AnyPublisher<MangaWithCover, Never> {
        guard let url = URL(string: "https://api.mangadex.org/cover?manga[]=\(manga.id)") else {
            return Just(MangaWithCover(manga: manga, coverURL: nil))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: CoverResponse.self, decoder: JSONDecoder())
            .map { coverResponse in
                if let fileName = coverResponse.data.first?.attributes.fileName {
                    let url = "https://uploads.mangadex.org/covers/\(manga.id)/\(fileName).256.jpg"
                    return MangaWithCover(manga: manga, coverURL: URL(string: url))
                } else {
                    return MangaWithCover(manga: manga, coverURL: nil)
                }
            }
            .replaceError(with: MangaWithCover(manga: manga, coverURL: nil))
            .eraseToAnyPublisher()
    }
}

// Wrapper for manga + cover URL
struct MangaWithCover: Identifiable {
    var id: String { manga.id }   // use MangaDex ID
    let manga: MangaData
    let coverURL: URL?
}

extension MangaViewModel {
    func fetchMangaSearch(query: String) {
        isLoading = true
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://api.mangadex.org/manga?title=\(encodedQuery)&limit=20") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: MangaResponse.self, decoder: JSONDecoder())
            .flatMap { response -> AnyPublisher<[MangaWithCover], Never> in
                let publishers = response.data.map { manga in
                    self.fetchCover(for: manga)
                }
                return Publishers.MergeMany(publishers)
                    .collect()
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.isLoading = false
            } receiveValue: { mangasWithCover in
                self.mangas = mangasWithCover
            }
            .store(in: &cancellables)
    }
}
