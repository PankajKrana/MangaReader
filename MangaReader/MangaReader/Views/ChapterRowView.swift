//
//  ChapterRowView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//

import SwiftUI

struct ChapterRowView: View {
    let chapter: Chapter

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(chapter.displayTitle)
                    .font(.body)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)

                Text(formatDate(chapter.attributes.publishAt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(chapter.attributes.pages) pages")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
    }

    private func formatDate(_ dateString: String) -> String {
        if let date = Self.isoFormatter.date(from: dateString) {
            return Self.displayFormatter.string(from: date)
        }
        return "Unknown date"
    }
}
