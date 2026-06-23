//
//  ChapterReaderView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//

import SwiftUI
import SwiftData
import Kingfisher

struct ChapterReaderView: View {
    let chapterId: String
    let chapterTitle: String
    let nextChapterId: String?

    // Manga context for reading-history tracking. Optional so existing
    // call sites without manga info still compile and simply skip tracking.
    var mangaId: String? = nil
    var mangaTitle: String? = nil
    var coverURLString: String? = nil
    /// Page to resume at when the chapter opens (from saved history).
    var resumePage: Int = 0

    @StateObject private var viewModel = ChapterReaderViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    /// Tracks the chapter currently displayed (it can change via "Next Chapter").
    @State private var activeChapterId: String = ""
    @State private var activeChapterTitle: String = ""
    @State private var didResume = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading pages...")
                    Spacer()
                }
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundStyle(.orange)
                    Text("Error loading pages")
                        .font(.headline)
                        .padding(.top)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        Task { await viewModel.fetchChapterPages(chapterId: chapterId) }
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                }
                .padding()
            } else if viewModel.pages.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "book.closed")
                        .font(.system(size: 50))
                        .foregroundStyle(.gray)
                    Text("No pages found")
                        .font(.headline)
                        .padding(.top)
                    Spacer()
                }
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.pages.enumerated()), id: \.offset) { index, pageURL in
                            KFImage(URL(string: pageURL))
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .background(Color.black.opacity(0.02))
                                .cornerRadius(4)
                                .id(index)
                                .onAppear {
                                    viewModel.currentPage = index
                                }
                        }

                        if let nextId = nextChapterId {
                            Button {
                                activeChapterId = nextId
                                didResume = true
                                Task { await viewModel.loadChapter(nextId) }
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Next Chapter")
                                        .font(.headline)
                                    Image(systemName: "chevron.right")
                                    Spacer()
                                }
                                .padding()
                                .background(Color.blue.opacity(0.15))
                                .foregroundStyle(.blue)
                                .cornerRadius(10)
                            }
                            .padding(.top, 16)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    }
                    .background(Color(UIColor.systemBackground))
                    .onAppear {
                        // Resume to the saved page once, after pages are loaded.
                        if !didResume, resumePage > 0, resumePage < viewModel.pages.count {
                            proxy.scrollTo(resumePage, anchor: .top)
                        }
                        didResume = true
                    }
                }
            }
        }
        .navigationTitle(activeChapterTitle.isEmpty ? chapterTitle : activeChapterTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
        .task(id: chapterId) {
            activeChapterId = chapterId
            activeChapterTitle = chapterTitle
            await viewModel.loadChapter(chapterId)
        }
        .onChange(of: viewModel.currentPage) {
            recordProgress()
        }
    }

    /// Saves the current reading position to history (no-op without manga info).
    private func recordProgress() {
        guard let mangaId, let mangaTitle, !viewModel.pages.isEmpty else { return }
        ReadingHistoryStore.record(
            in: modelContext,
            mangaId: mangaId,
            mangaTitle: mangaTitle,
            coverURLString: coverURLString,
            chapterId: activeChapterId.isEmpty ? chapterId : activeChapterId,
            chapterTitle: activeChapterTitle.isEmpty ? chapterTitle : activeChapterTitle,
            currentPage: viewModel.currentPage,
            totalPages: viewModel.pages.count
        )
    }
}
