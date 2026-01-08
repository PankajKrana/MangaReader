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
    @State private var searchHistory: [String] = []
    @State private var showFilters = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search Manga...", text: $query)
                            .textFieldStyle(PlainTextFieldStyle())
                            .onSubmit {
                                searchManga(query: query)
                            }
                        
                        if !query.isEmpty {
                            Button(action: {
                                query = ""
                                viewModel.mangas = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Button(action: {
                        showFilters.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                
                // Search suggestions or history
                if query.isEmpty && !searchHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Recent Searches")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Clear") {
                                searchHistory.removeAll()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        
                        ForEach(searchHistory.prefix(5), id: \.self) { historyItem in
                            Button(action: {
                                query = historyItem
                                searchManga(query: historyItem)
                            }) {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.secondary)
                                    Text(historyItem)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .background(Color(UIColor.systemBackground))
                }
                
                // Results
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else if viewModel.mangas.isEmpty && !query.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No results found")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text("Try searching with different keywords")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else if !viewModel.mangas.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.mangas) { manga in
                                NavigationLink(destination: MangaDetailView(manga: manga)) {
                                    SearchResultRowView(manga: manga)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Search for manga")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text("Discover thousands of manga titles")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
            .navigationTitle("Search")
            .sheet(isPresented: $showFilters) {
                SearchFiltersView()
            }
        }
    }
    
    private func searchManga(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedQuery.isEmpty else {
            viewModel.mangas = []
            return
        }
        
        // Add to search history
        if !searchHistory.contains(trimmedQuery) {
            searchHistory.insert(trimmedQuery, at: 0)
            if searchHistory.count > 10 {
                searchHistory.removeLast()
            }
        }
        
        viewModel.fetchMangaSearch(query: trimmedQuery)
    }
}
#Preview {
    SearchView()
}
