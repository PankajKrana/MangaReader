//
//  SearchFiltersView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//

import SwiftUI

struct SearchFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGenres: Set<String>
    @State private var selectedStatus: String
    @State private var selectedYear: String

    let onApply: (MangaSearchFilters) -> Void

    let genres = ["Action", "Adventure", "Comedy", "Drama", "Fantasy", "Horror", "Romance", "Sci-Fi", "Slice of Life", "Sports"]
    let statuses = ["any", "ongoing", "completed", "hiatus", "cancelled"]
    let years = ["any", "2024", "2023", "2022", "2021", "2020"]

    init(initialFilters: MangaSearchFilters = .default, onApply: @escaping (MangaSearchFilters) -> Void = { _ in }) {
        _selectedGenres = State(initialValue: initialFilters.genres)
        _selectedStatus = State(initialValue: initialFilters.status)
        _selectedYear = State(initialValue: initialFilters.year)
        self.onApply = onApply
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Genres") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(genres, id: \.self) { genre in
                            Button {
                                if selectedGenres.contains(genre) {
                                    selectedGenres.remove(genre)
                                } else {
                                    selectedGenres.insert(genre)
                                }
                            } label: {
                                Text(genre)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedGenres.contains(genre) ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundStyle(selectedGenres.contains(genre) ? .white : .primary)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section("Status") {
                    Picker("Status", selection: $selectedStatus) {
                        ForEach(statuses, id: \.self) { status in
                            Text(status.capitalized).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Year") {
                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        selectedGenres.removeAll()
                        selectedStatus = "any"
                        selectedYear = "any"
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        onApply(MangaSearchFilters(genres: selectedGenres, status: selectedStatus, year: selectedYear))
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
