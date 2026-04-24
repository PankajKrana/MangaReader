//
//  MangaDetailView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//

import SwiftUI
import Kingfisher

struct MangaDetailView: View {
    let manga: MangaWithCover
    @StateObject private var viewModel = MangaDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    if let url = manga.coverImageURL {
                        KFImage(url)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 180)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 180)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(manga.displayTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)

                        if !manga.displayDescription.isEmpty {
                            Text(manga.displayDescription)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineLimit(6)
                                .multilineTextAlignment(.leading)
                        }

                        if !manga.manga.attributes.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(manga.manga.attributes.tags.prefix(5)), id: \.id) { tag in
                                        Text(tag.attributes.displayName)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundStyle(.blue)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal, 1)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal)

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Chapters")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Spacer()

                        Text("\(viewModel.chapters.count) chapters")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Loading chapters...")
                            Spacer()
                        }
                        .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(.orange)
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                        }
                        .padding()
                    } else if viewModel.chapters.isEmpty {
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: "book.closed")
                                    .foregroundStyle(.gray)
                                Text("No chapters available")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                    } else {
                        LazyVStack(spacing: 1) {
                            ForEach(viewModel.chapters) { chapter in
                                NavigationLink(destination: ChapterReaderView(chapterId: chapter.id, chapterTitle: chapter.displayTitle, nextChapterId: nil)) {
                                    ChapterRowView(chapter: chapter)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(manga.displayTitle)
        .navigationBarTitleDisplayMode(.large)
        .task(id: manga.manga.id) {
            await viewModel.fetchChapters(for: manga.manga.id)
        }
    }
}
