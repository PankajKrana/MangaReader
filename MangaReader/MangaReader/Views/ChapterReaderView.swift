//
//  ChapterReaderView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//

import SwiftUI
import Kingfisher

struct ChapterReaderView: View {
    let chapterId: String
    let chapterTitle: String
    let nextChapterId: String?

    @StateObject private var viewModel = ChapterReaderViewModel()
    @Environment(\.dismiss) private var dismiss

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
                ScrollView(.vertical) {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.pages.enumerated()), id: \.offset) { index, pageURL in
                            KFImage(URL(string: pageURL))
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .background(Color.black.opacity(0.02))
                                .cornerRadius(4)
                                .onAppear {
                                    viewModel.currentPage = index
                                }
                        }

                        if let nextId = nextChapterId {
                            Button {
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
            }
        }
        .navigationTitle(chapterTitle)
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
            await viewModel.loadChapter(chapterId)
        }
    }
}
