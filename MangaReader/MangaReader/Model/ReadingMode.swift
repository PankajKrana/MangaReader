//
//  ReadingMode.swift
//  MangaReader
//
//  How chapter pages are laid out in the reader.
//

import Foundation

enum ReadingMode: String, CaseIterable, Identifiable {
    case vertical
    case leftToRight
    case rightToLeft

    var id: String { rawValue }

    var label: String {
        switch self {
        case .vertical: return "Vertical"
        case .leftToRight: return "Left → Right"
        case .rightToLeft: return "Right → Left"
        }
    }

    var icon: String {
        switch self {
        case .vertical: return "arrow.up.arrow.down"
        case .leftToRight: return "arrow.right"
        case .rightToLeft: return "arrow.left"
        }
    }

    var isPaged: Bool { self != .vertical }
}
