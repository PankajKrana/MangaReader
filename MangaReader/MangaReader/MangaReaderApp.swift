//
//  MangaReaderApp.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import SwiftUI
import SwiftData

@main
struct MangaReaderApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(for: [ReadingHistoryEntry.self, FavoriteManga.self])
    }
}
