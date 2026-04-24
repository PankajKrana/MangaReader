//
//  MangaSearchFilters.swift
//  MangaReader
//
//  Created by Codex on 4/24/26.
//

import Foundation

struct MangaSearchFilters: Equatable {
    let genres: Set<String>
    let status: String
    let year: String

    static let `default` = MangaSearchFilters(genres: [], status: "any", year: "any")
}
