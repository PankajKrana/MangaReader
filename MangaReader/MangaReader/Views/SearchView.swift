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
    @State private var activeFilters = MangaSearchFilters.default

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        TextField("Search Manga...", text: $query)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                searchManga(query: query)
                            }

                        if !query.isEmpty {
                            Button {
                                query = ""
                                viewModel.mangas = []
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .accessibilityLabel("Clear search")
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button {
                        showFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                    .accessibilityLabel("Open search filters")
                }
                .padding()

                if query.isEmpty && !searchHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Recent Searches")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button("Clear") {
                                searchHistory.removeAll()
                            }
                            .font(.caption)
                            .foregroundStyle(.blue)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)

                        ForEach(searchHistory.prefix(5), id: \.self) { historyItem in
                            Button {
                                query = historyItem
                                searchManga(query: historyItem)
                            } label: {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundStyle(.secondary)
                                    Text(historyItem)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .background(Color(UIColor.systemBackground))
                }

                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else if viewModel.mangas.isEmpty && !query.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray)

                        Text("No results found")
                            .font(.title3)
                            .fontWeight(.medium)

                        Text("Try searching with different keywords")
                            .font(.body)
                            .foregroundStyle(.secondary)
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
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray)

                        Text("Search for manga")
                            .font(.title3)
                            .fontWeight(.medium)

                        Text("Discover thousands of manga titles")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
            .navigationTitle("Search")
            .sheet(isPresented: $showFilters) {
                SearchFiltersView(initialFilters: activeFilters) { filters in
                    activeFilters = filters
                    if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        searchManga(query: query)
                    }
                }
            }
        }
    }

    private func searchManga(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedQuery.isEmpty else {
            viewModel.mangas = []
            return
        }

        if !searchHistory.contains(trimmedQuery) {
            searchHistory.insert(trimmedQuery, at: 0)
            if searchHistory.count > 10 {
                searchHistory.removeLast()
            }
        }

        Task {
            await viewModel.fetchMangaSearch(query: trimmedQuery, filters: activeFilters)
        }
    }
}

#Preview {
    SearchView()
}
