//
//  MangaDetailView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//

import SwiftUI
import SwiftData
import Kingfisher

struct MangaDetailView: View {
    let manga: MangaWithCover
    @StateObject private var viewModel = MangaDetailViewModel()
    @Environment(\.modelContext) private var modelContext

    /// Favorites for this manga's id — non-empty means it's favorited.
    @Query private var favorites: [FavoriteManga]

    init(manga: MangaWithCover) {
        self.manga = manga
        let id = manga.manga.id
        _favorites = Query(filter: #Predicate { $0.mangaId == id })
    }

    private var isFavorite: Bool { !favorites.isEmpty }

    /// Reflects the view model's selection but routes user changes through
    /// `select(language:)`, which reloads chapters and skips no-op picks.
    private var languageBinding: Binding<String?> {
        Binding(
            get: { viewModel.selectedLanguage },
            set: { newValue in
                Task { await viewModel.select(language: newValue) }
            }
        )
    }

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

                if !viewModel.availableLanguages.isEmpty {
                    HStack {
                        Text("Language")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Spacer()

                        Picker("Language", selection: languageBinding) {
                            ForEach(viewModel.availableLanguages, id: \.self) { code in
                                Text(code.languageDisplayName).tag(String?.some(code))
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(.horizontal)
                }

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
                                NavigationLink(value: chapter) {
                                    ChapterRowView(chapter: chapter)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .navigationDestination(for: Chapter.self) { chapter in
            ChapterReaderView(
                chapterId: chapter.id,
                chapterTitle: chapter.displayTitle,
                nextChapterId: nil,
                mangaId: manga.manga.id,
                mangaTitle: manga.displayTitle,
                coverURLString: manga.coverImageURL?.absoluteString
            )
        }
        .navigationTitle(manga.displayTitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    FavoritesStore.toggle(in: modelContext, manga: manga)
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : .primary)
                }
                .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
            }
        }
        .task(id: manga.manga.id) {
            await viewModel.start(
                mangaId: manga.manga.id,
                availableLanguages: manga.manga.attributes.availableTranslatedLanguages,
                originalLanguage: manga.manga.attributes.originalLanguage
            )
        }
    }
}
