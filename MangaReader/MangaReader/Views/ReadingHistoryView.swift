//
//  ReadingHistoryView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//

import SwiftUI
import SwiftData
import Kingfisher

struct ReadingHistoryView: View {
    @Query(sort: \ReadingHistoryEntry.updatedAt, order: .reverse)
    private var history: [ReadingHistoryEntry]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if history.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 44))
                        .foregroundStyle(.gray)
                    Text("Your recently read manga will appear here")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(history) { entry in
                            NavigationLink {
                                ChapterReaderView(
                                    chapterId: entry.chapterId,
                                    chapterTitle: entry.chapterTitle,
                                    nextChapterId: nil,
                                    mangaId: entry.mangaId,
                                    mangaTitle: entry.mangaTitle,
                                    coverURLString: entry.coverURLString,
                                    resumePage: entry.currentPage
                                )
                            } label: {
                                ReadingHistoryCard(entry: entry)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    if let index = history.firstIndex(of: entry) {
                                        let idxSet = IndexSet(integer: index)
                                        delete(at: idxSet)
                                    }
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Reading History")
        .navigationBarTitleDisplayMode(.large)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(history[index])
        }
        try? modelContext.save()
    }
}

private struct ReadingHistoryRow: View {
    let entry: ReadingHistoryEntry

    var body: some View {
        HStack(spacing: 12) {
            if let url = entry.coverURL {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 64)
                    .clipped()
                    .cornerRadius(6)
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 44, height: 64)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.mangaTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Text(entry.chapterTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text("Page \(entry.currentPage + 1) of \(entry.totalPages)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

private struct ReadingHistoryCard: View {
    let entry: ReadingHistoryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                if let url = entry.coverURL {
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

            Text(entry.mangaTitle)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
                .frame(maxWidth: 110, alignment: .leading)

            Text(entry.chapterTitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: 110, alignment: .leading)

            Text("Page \(entry.currentPage + 1) of \(entry.totalPages)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: 110, alignment: .leading)
        }
    }
}

#Preview {
    ReadingHistoryView()
        .modelContainer(for: ReadingHistoryEntry.self, inMemory: true)
}
