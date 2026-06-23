//
//  String+Language.swift
//  MangaReader
//
//

import Foundation

extension String {
    var languageDisplayName: String {
        Locale.current.localizedString(forIdentifier: self)
            ?? Locale.current.localizedString(forLanguageCode: self)
            ?? self
    }
}
