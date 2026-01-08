//
//  ContentView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass")
                    Text("Search")
                }
                .tag(1)
            
            DownloadsView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "arrow.down.circle.fill" : "arrow.down.circle")
                    Text("Downloads")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "gear.circle.fill" : "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainView()
}
