//
//  SettingView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("wifiOnly") private var wifiOnly = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Account Section
                Section(header: Text("Account")) {
                    NavigationLink(destination: Text("Profile Screen")) {
                        Label("Profile", systemImage: "person.circle")
                    }
                    
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    .alert("Are you sure you want to logout?", isPresented: $showLogoutAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Logout", role: .destructive) {
                            print("User logged out")
                        }
                    }
                }
                
                // MARK: - Preferences Section
                Section(header: Text("Preferences")) {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                    Toggle(isOn: $wifiOnly) {
                        Label("Wi-Fi Only Downloads", systemImage: "wifi")
                    }
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                }
                
                // MARK: - About Section
                Section(header: Text("About")) {
                    NavigationLink(destination: Text("Privacy Policy")) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                    NavigationLink(destination: Text("Terms & Conditions")) {
                        Label("Terms & Conditions", systemImage: "doc.text")
                    }
                    HStack {
                        Label("App Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

