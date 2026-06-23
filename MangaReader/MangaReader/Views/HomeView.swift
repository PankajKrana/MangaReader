//
//  HomeView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import SwiftUI
import SwiftData
import Kingfisher

struct HomeView: View {
    @StateObject private var viewModel = MangaViewModel()

    @Query(sort: \ReadingHistoryEntry.updatedAt, order: .reverse)
    private var history: [ReadingHistoryEntry]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    if let seasonalManga = viewModel.mangas.first {
                        NavigationLink(value: seasonalManga) {
                            ZStack(alignment: .bottomLeading) {
                                if let url = seasonalManga.coverImageURL {
                                    KFImage(url)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 180)
                                        .clipped()
                                        .cornerRadius(16)
                                } else {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 180)
                                }

                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                .cornerRadius(16)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Seasonal")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text(seasonalManga.displayTitle)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .lineLimit(2)
                                }
                                .padding()
                            }
                        }
                        .buttonStyle(.plain)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 180)
                            Text("Seasonal")
                                .foregroundStyle(.white)
                                .font(.headline)
                        }
                    }

                    if !history.isEmpty {
                        ContinueReadingSection(entries: Array(history.prefix(10)))
                    }

                    Text("Latest updates")
                        .font(.headline)

                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(viewModel.mangas) { manga in
                                NavigationLink(value: manga) {
                                    MangaRowView(manga: manga)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationDestination(for: MangaWithCover.self) { manga in
                MangaDetailView(manga: manga)
            }
            .navigationDestination(for: ReadingHistoryEntry.self) { entry in
                ChapterReaderView(
                    chapterId: entry.chapterId,
                    chapterTitle: entry.chapterTitle,
                    nextChapterId: nil,
                    mangaId: entry.mangaId,
                    mangaTitle: entry.mangaTitle,
                    coverURLString: entry.coverURLString,
                    resumePage: entry.currentPage
                )
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.fetchManga() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("Refresh manga list")
                }
            }
            .task {
                await viewModel.fetchManga()
            }
        }
    }
}

private struct ContinueReadingSection: View {
    let entries: [ReadingHistoryEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Continue Reading")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(entries) { entry in
                        NavigationLink(value: entry) {
                            ContinueReadingCard(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct ContinueReadingCard: View {
    let entry: ReadingHistoryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .bottom) {
                if let url = entry.coverURL {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 160)
                        .clipped()
                        .cornerRadius(10)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 110, height: 160)
                }

                if entry.totalPages > 0 {
                    ProgressView(value: Double(entry.currentPage + 1),
                                 total: Double(entry.totalPages))
                        .tint(.white)
                        .padding(.horizontal, 6)
                        .padding(.bottom, 4)
                }
            }

            Text(entry.mangaTitle)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .frame(width: 110, alignment: .leading)

            Text(entry.chapterTitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(width: 110, alignment: .leading)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: ReadingHistoryEntry.self, inMemory: true)
}
