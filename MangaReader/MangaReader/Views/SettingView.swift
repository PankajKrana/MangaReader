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
    @AppStorage("autoDownload") private var autoDownload = false
    @AppStorage("readingDirection") private var readingDirection = "leftToRight"
    @State private var showLogoutAlert = false
    @State private var showClearCacheAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Account Section
                Section(header: Text("Account")) {
                    NavigationLink(destination: ProfileView()) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                            VStack(alignment: .leading) {
                                Text("Profile")
                                    .font(.body)
                                Text("Manage your account")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    NavigationLink(destination: ReadingHistoryView()) {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                            VStack(alignment: .leading) {
                                Text("Reading History")
                                    .font(.body)
                                Text("View your reading progress")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .font(.title3)
                            Text("Logout")
                        }
                    }
                    .alert("Are you sure you want to logout?", isPresented: $showLogoutAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Logout", role: .destructive) {
                            // Handle logout
                            print("User logged out")
                        }
                    }
                }
                
                // MARK: - Reading Preferences
                Section(header: Text("Reading Preferences")) {
                    Picker("Reading Direction", selection: $readingDirection) {
                        Text("Left to Right").tag("leftToRight")
                        Text("Right to Left").tag("rightToLeft")
                        Text("Vertical").tag("vertical")
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Toggle(isOn: $autoDownload) {
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.orange)
                                .font(.title3)
                            VStack(alignment: .leading) {
                                Text("Auto Download")
                                Text("Download new chapters automatically")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // MARK: - App Preferences
                Section(header: Text("App Preferences")) {
                    Toggle(isOn: $isDarkMode) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.purple)
                                .font(.title3)
                            Text("Dark Mode")
                        }
                    }
                    
                    Toggle(isOn: $wifiOnly) {
                        HStack {
                            Image(systemName: "wifi")
                                .foregroundColor(.blue)
                                .font(.title3)
                            VStack(alignment: .leading) {
                                Text("Wi-Fi Only Downloads")
                                Text("Prevent mobile data usage")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Toggle(isOn: $notificationsEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.red)
                                .font(.title3)
                            VStack(alignment: .leading) {
                                Text("Notifications")
                                Text("Get updates on new chapters")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // MARK: - Storage Section
                Section(header: Text("Storage")) {
                    HStack {
                        Image(systemName: "internaldrive.fill")
                            .foregroundColor(.gray)
                            .font(.title3)
                        VStack(alignment: .leading) {
                            Text("Cache Size")
                            Text("245 MB used")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Clear") {
                            showClearCacheAlert = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .alert("Clear Cache?", isPresented: $showClearCacheAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Clear", role: .destructive) {
                            // Handle cache clearing
                        }
                    } message: {
                        Text("This will free up storage space but may slow down the app temporarily.")
                    }
                }
                
                // MARK: - About Section
                Section(header: Text("About")) {
                    NavigationLink(destination: Text("Privacy Policy")) {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                            Text("Privacy Policy")
                        }
                    }
                    
                    NavigationLink(destination: Text("Terms & Conditions")) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                            Text("Terms & Conditions")
                        }
                    }
                    
                    NavigationLink(destination: Text("Help & Support")) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.orange)
                                .font(.title3)
                            Text("Help & Support")
                        }
                    }
                    
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title3)
                        Text("App Version")
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
