//
//  DownloadManager.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//

import Foundation
import Combine

@MainActor
final class DownloadManager: ObservableObject {
    static let shared = DownloadManager()

    @Published private(set) var downloadedMangas: [MangaWithCover] = []
    @Published var downloadProgress: [String: Double] = [:]

    private let recordsKey = "download_records"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var recordsByMangaId: [String: DownloadRecord] = [:]

    private init() {
        loadRecords()
    }

    func refreshDownloads() {
        loadRecords()
    }

    func clearAllDownloads() {
        downloadedMangas.removeAll()
        recordsByMangaId.removeAll()
        persistRecords()
    }

    func setDownloadedMangas(_ mangas: [MangaWithCover]) {
        downloadedMangas = mangas
    }

    func upsertRecord(for mangaId: String, chapterCount: Int, sizeInMB: Int, downloadDate: Date = .now) {
        recordsByMangaId[mangaId] = DownloadRecord(
            mangaId: mangaId,
            chapterCount: chapterCount,
            sizeInMB: sizeInMB,
            downloadDate: downloadDate
        )
        persistRecords()
    }

    func removeRecord(for mangaId: String) {
        recordsByMangaId.removeValue(forKey: mangaId)
        downloadedMangas.removeAll { $0.manga.id == mangaId }
        persistRecords()
    }

    func getDownloadedChapterCount(for mangaId: String) -> Int {
        recordsByMangaId[mangaId]?.chapterCount ?? 0
    }

    func getDownloadDate(for mangaId: String) -> String {
        guard let downloadDate = recordsByMangaId[mangaId]?.downloadDate else { return "Not downloaded" }
        return downloadDate.formatted(.relative(presentation: .named))
    }

    func getDownloadSize(for mangaId: String) -> String {
        guard let sizeInMB = recordsByMangaId[mangaId]?.sizeInMB else { return "0 MB" }
        return "\(sizeInMB) MB"
    }

    private func loadRecords() {
        guard let data = UserDefaults.standard.data(forKey: recordsKey),
              let records = try? decoder.decode([DownloadRecord].self, from: data) else {
            recordsByMangaId = [:]
            return
        }

        recordsByMangaId = Dictionary(uniqueKeysWithValues: records.map { ($0.mangaId, $0) })
    }

    private func persistRecords() {
        let records = Array(recordsByMangaId.values)
        guard let data = try? encoder.encode(records) else { return }
        UserDefaults.standard.set(data, forKey: recordsKey)
    }
}

private struct DownloadRecord: Codable {
    let mangaId: String
    let chapterCount: Int
    let sizeInMB: Int
    let downloadDate: Date
}
