import Foundation
import Combine

class DownloadManager: ObservableObject {
    static let shared = DownloadManager()
    
    @Published var downloadedMangas: [MangaWithCover] = []
    @Published var downloadProgress: [String: Double] = [:]
    
    private init() {}
    
    func refreshDownloads() {
        // Refresh download list
    }
    
    func clearAllDownloads() {
        downloadedMangas.removeAll()
    }
    
    func getDownloadedChapterCount(for mangaId: String) -> Int {
        // Return number of downloaded chapters
        return Int.random(in: 5...50)
    }
    
    func getDownloadDate(for mangaId: String) -> String {
        return "2 days ago"
    }
    
    func getDownloadSize(for mangaId: String) -> String {
        return "\(Int.random(in: 50...500))MB"
    }
}
