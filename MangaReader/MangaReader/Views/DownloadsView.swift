//
//  DownloadsView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import SwiftUI

import SwiftUI
import Kingfisher

struct DownloadsView: View {
    @StateObject private var downloadManager = DownloadManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if downloadManager.downloadedMangas.isEmpty {
                        // Empty state
                        VStack(spacing: 16) {
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No downloads yet")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Text("Downloaded manga will appear here for offline reading")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 60)
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        // Downloaded manga list
                        LazyVStack(spacing: 12) {
                            ForEach(downloadManager.downloadedMangas) { manga in
                                NavigationLink(destination: MangaDetailView(manga: manga)) {
                                    DownloadedMangaRowView(manga: manga)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Downloads")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            downloadManager.refreshDownloads()
                        }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                        
                        Button(role: .destructive, action: {
                            downloadManager.clearAllDownloads()
                        }) {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}


#Preview {
    DownloadsView()
}
