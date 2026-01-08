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
                // Manga Cover and Info
                HStack(alignment: .top, spacing: 16) {
                    // Cover Image
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
                    
                    // Manga Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(manga.displayTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        
                        if !manga.displayDescription.isEmpty {
                            Text(manga.displayDescription)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineLimit(6)
                                .multilineTextAlignment(.leading)
                        }
                        
                        // Tags
                        if !manga.manga.attributes.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(manga.manga.attributes.tags.prefix(5)), id: \.id) { tag in
                                        Text(tag.attributes.displayName)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
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
                
                // Chapters Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Chapters")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(viewModel.chapters.count) chapters")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                                    .foregroundColor(.orange)
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
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
                                    .foregroundColor(.gray)
                                Text("No chapters available")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                    } else {
                        LazyVStack(spacing: 1) {
                            ForEach(viewModel.chapters) { chapter in
                                NavigationLink(destination: ChapterReaderView(chapterId: chapter.id, chapterTitle: chapter.displayTitle, nextChapterId: "")) {
                                    ChapterRowView(chapter: chapter)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(manga.displayTitle)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.fetchChapters(for: manga.manga.id)
        }
    }
}

