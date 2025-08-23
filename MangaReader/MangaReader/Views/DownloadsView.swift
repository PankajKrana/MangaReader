//
//  DownloadsView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import SwiftUI

struct DownloadsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    // Currently empty; can add downloaded manga list here later
                    Text("No downloads yet")
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
            }
            .navigationTitle("Downloads")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
    }
}

#Preview {
    DownloadsView()
}
