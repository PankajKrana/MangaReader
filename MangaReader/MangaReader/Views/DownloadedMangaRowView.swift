//
//  DownloadedMangaRowView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//


import SwiftUI
import Kingfisher

struct DownloadedMangaRowView: View {
    let manga: MangaWithCover
    @StateObject private var downloadManager = DownloadManager.shared
    
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
                
                Text("\(downloadManager.getDownloadedChapterCount(for: manga.manga.id)) chapters downloaded")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Downloaded \(downloadManager.getDownloadDate(for: manga.manga.id))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
                
                Text("\(downloadManager.getDownloadSize(for: manga.manga.id))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}
