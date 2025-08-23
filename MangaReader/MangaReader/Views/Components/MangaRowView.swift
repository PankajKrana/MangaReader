//
//  MangaRowView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import SwiftUI
import Kingfisher

struct MangaRowView: View {
    var manga: MangaWithCover
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Cover image
            if let url = manga.coverURL {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 100)
                    .cornerRadius(8)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 100)
            }
            
            // Manga details
            VStack(alignment: .leading, spacing: 6) {
                Text(manga.manga.attributes.displayTitle)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Label("N/A", systemImage: "star.fill")
                        .font(.caption)
                    Label("N/A", systemImage: "person.2.fill")
                        .font(.caption)
                    Text(manga.manga.attributes.status ?? "Unknown")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    MangaRowView(
        manga: MangaWithCover(
            manga: MangaData(
                id: "123",
                attributes: MangaAttributes(
                    title: ["en": "Attack on Titan"],
                    status: "Ongoing",
                    version: 1
                )
            ),
            coverURL: URL(string: "https://uploads.mangadex.org/covers/123/sample.jpg")
        )
    )
}
