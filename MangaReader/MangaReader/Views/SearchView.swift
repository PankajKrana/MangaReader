//
//  SearchView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import SwiftUI
import Kingfisher

struct SearchView: View {
    @StateObject private var viewModel = MangaViewModel()
    @State private var query: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                HStack(spacing: 12) {
                    TextField("Search Manga...", text: $query)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                        .onChange(of: query) { newValue in
                            searchManga(query: newValue)
                        }
                    
                    Button(action: {
                        searchManga(query: query)
                    }) {
                        Text("Search")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
                .padding()
                
                // Results
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if viewModel.mangas.isEmpty && !query.isEmpty {
                    Text("No results found for \"\(query)\"")
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.mangas) { manga in
                                MangaRowView(manga: manga)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Search")
        }
    }
    
    private func searchManga(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            viewModel.mangas = []
            return
        }
        
        viewModel.fetchMangaSearch(query: query)
    }
}
