import Foundation
import Combine

class MangaDetailViewModel: ObservableObject {
    @Published var chapters: [Chapter] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://api.mangadex.org"
    
    func fetchChapters(for mangaId: String) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/manga/\(mangaId)/feed?translatedLanguage[]=en&limit=100&order[chapter]=asc") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                do {
                    let chapterResponse = try JSONDecoder().decode(ChapterResponse.self, from: data)
                    self?.chapters = chapterResponse.data.sorted { chapter1, chapter2 in
                        let num1 = Float(chapter1.attributes.chapter ?? "0") ?? 0
                        let num2 = Float(chapter2.attributes.chapter ?? "0") ?? 0
                        return num1 < num2
                    }
                } catch {
                    self?.errorMessage = "Failed to decode chapters: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
}
