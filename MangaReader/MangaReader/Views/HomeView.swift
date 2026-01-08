//
//  HomeView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import SwiftUI

import SwiftUI
import Kingfisher

struct HomeView: View {
    @StateObject private var viewModel = MangaViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    
                    if let seasonalManga = viewModel.mangas.first {
                        NavigationLink(destination: MangaDetailView(manga: seasonalManga)) {
                            ZStack(alignment: .bottomLeading) {
                                if let url = seasonalManga.coverImageURL {
                                    KFImage(url)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 180)
                                        .clipped()
                                        .cornerRadius(16)
                                } else {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 180)
                                }
                                
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                .cornerRadius(16)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Seasonal")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(seasonalManga.displayTitle)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                }
                                .padding()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        // Placeholder if no manga yet
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 180)
                            Text("Seasonal")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    }
                    
                    // Latest updates section
                    Text("Latest updates")
                        .font(.headline)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(viewModel.mangas) { manga in
                                NavigationLink(destination: MangaDetailView(manga: manga)) {
                                    MangaRowView(manga: manga)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.fetchManga()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                viewModel.fetchManga()
            }
        }
    }
}
#Preview {
    HomeView()
}
