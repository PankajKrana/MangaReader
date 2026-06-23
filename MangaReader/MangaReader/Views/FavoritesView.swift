//
//  FavoritesView.swift
//  MangaReader
//
//  Grid of favorited manga, persisted with SwiftData.
//

import SwiftUI
import SwiftData
import Kingfisher

struct FavoritesView: View {
    @Query(sort: \FavoriteManga.createdAt, order: .reverse)
    private var favorites: [FavoriteManga]
    @Environment(\.modelContext) private var modelContext

    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 16)]

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "heart")
                            .font(.system(size: 44))
                            .foregroundStyle(.gray)
                        Text("No favorites yet")
                            .font(.headline)
                        Text("Tap the heart on a manga to add it here")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(favorites) { favorite in
                                favoriteCell(favorite)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }

    @ViewBuilder
    private func favoriteCell(_ favorite: FavoriteManga) -> some View {
        Group {
            if let manga = favorite.mangaWithCover {
                NavigationLink(destination: MangaDetailView(manga: manga)) {
                    FavoriteCard(favorite: favorite)
                }
                .buttonStyle(.plain)
            } else {
                // Fallback if stored data can't be decoded.
                FavoriteCard(favorite: favorite)
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                FavoritesStore.remove(in: modelContext, mangaId: favorite.mangaId)
            } label: {
                Label("Remove", systemImage: "heart.slash")
            }
        }
    }
}

private struct FavoriteCard: View {
    let favorite: FavoriteManga

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                if let url = favorite.coverURL {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 110, height: 160)
            .clipped()
            .cornerRadius(8)

            Text(favorite.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(width: 110, alignment: .leading)
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: FavoriteManga.self, inMemory: true)
}
