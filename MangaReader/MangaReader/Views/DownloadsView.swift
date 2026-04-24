//
//  DownloadsView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import SwiftUI

struct DownloadsView: View {
    @ObservedObject private var downloadManager = DownloadManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if downloadManager.downloadedMangas.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 60))
                                .foregroundStyle(.gray)

                            Text("No downloads yet")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)

                            Text("Downloaded manga will appear here for offline reading")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 60)
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(downloadManager.downloadedMangas) { manga in
                                NavigationLink(destination: MangaDetailView(manga: manga)) {
                                    DownloadedMangaRowView(manga: manga)
                                }
                                .buttonStyle(.plain)
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
                        Button {
                            downloadManager.refreshDownloads()
                        } label: {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }

                        Button(role: .destructive) {
                            downloadManager.clearAllDownloads()
                        } label: {
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
