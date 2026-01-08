//
//  SearchResultRowView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//


import SwiftUI
import Kingfisher

struct SearchResultRowView: View {
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
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(manga.displayTitle)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if !manga.displayDescription.isEmpty {
                    Text(manga.displayDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                // Tags
                if !manga.manga.attributes.tags.isEmpty {
                    HStack {
                        ForEach(Array(manga.manga.attributes.tags.prefix(2)), id: \.id) { tag in
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
}

