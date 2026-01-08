//
//  ProfileView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//


import SwiftUI

struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Image
                Circle()
                    .fill(Color.blue)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    )
                
                // User Info
                VStack(spacing: 8) {
                    Text("Manga Reader")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("manga.reader@example.com")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                // Stats
                HStack(spacing: 30) {
                    VStack {
                        Text("42")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Read")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("128")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Chapters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("15")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Downloads")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
    }
}
