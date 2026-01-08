//
//  ChapterReaderViewModel.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//


import Foundation
import Combine

class ChapterReaderViewModel: ObservableObject {
    @Published var pages: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 0
    
    // FIXED: Changed from mangadx.org to mangadex.org
    private let baseURL = "https://api.mangadex.org"
    private var baseImageURL = ""
    
    func fetchChapterPages(chapterId: String) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/at-home/server/\(chapterId)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        print("Fetching chapter pages from: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    print("Network error: \(error)")
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                // Debug: Print raw response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response: \(jsonString)")
                }
                
                do {
                    let chapterPages = try JSONDecoder().decode(ChapterPages.self, from: data)
                    self?.baseImageURL = chapterPages.baseUrl
                    self?.pages = chapterPages.chapter.data.map { filename in
                        "\(chapterPages.baseUrl)/data/\(chapterPages.chapter.hash)/\(filename)"
                    }
                    print("Successfully loaded \(self?.pages.count ?? 0) pages")
                } catch {
                    self?.errorMessage = "Failed to decode pages: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    func loadChapter(_ chapterId: String) {
        // Reset state for a new chapter
        pages = []
        errorMessage = nil
        currentPage = 0
        isLoading = false
        baseImageURL = ""
        fetchChapterPages(chapterId: chapterId)
    }
}

