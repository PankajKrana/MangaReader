//
//  MangaRowView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import SwiftUI
import Kingfisher

struct MangaRowView: View {
    let manga: MangaWithCover
    
    var body: some View {
        HStack(spacing: 16) {
            // Cover image
            if let url = manga.coverImageURL {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 80)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 80)
                    .overlay(
                        Image(systemName: "book.closed")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(manga.displayTitle)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(manga.displayDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Status and year
                HStack(spacing: 8) {
                    Text(manga.displayStatus)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(statusColor(manga.manga.attributes.status))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                    if let year = manga.manga.attributes.year {
                        Text(String(year))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    // FIXED: Show last chapter info if available
                    if let lastChapter = manga.manga.attributes.lastChapter {
                        Text("Ch. \(lastChapter)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Genre tags
                if !manga.genreTags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(manga.genreTags.prefix(2)), id: \.id) { tag in
                            Text(tag.attributes.displayName)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                        Spacer()
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "ongoing": return .green
        case "completed": return .blue
        case "hiatus": return .orange
        case "cancelled": return .red
        default: return .gray
        }
    }
}
