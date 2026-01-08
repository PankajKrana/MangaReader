//
//  ReadingHistoryView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//



import SwiftUI

struct ReadingHistoryView: View {
    var body: some View {
        List {
            Text("Your recently read manga will appear here")
                .foregroundColor(.secondary)
                .padding()
        }
        .navigationTitle("Reading History")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    ReadingHistoryView()
}
