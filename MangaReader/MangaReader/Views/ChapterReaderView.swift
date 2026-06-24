//
//  ChapterReaderView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 08/01/26.
//

import SwiftUI
import SwiftData
import UIKit
import Kingfisher

struct ChapterReaderView: View {
    let chapterId: String
    let chapterTitle: String
    let nextChapterId: String?

    // Manga context for reading-history tracking. Optional so existing
    // call sites without manga info still compile and simply skip tracking.
    var mangaId: String? = nil
    var mangaTitle: String? = nil
    var coverURLString: String? = nil
    /// Page to resume at when the chapter opens (from saved history).
    var resumePage: Int = 0

    @StateObject private var viewModel = ChapterReaderViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Persisted reader preferences.
    @AppStorage("readingMode") private var readingModeRaw = ReadingMode.vertical.rawValue

    // Reader UI state.
    @State private var pageSelection = 0
    @State private var showControls = false
    @State private var brightness = 0.5
    @State private var originalBrightness: CGFloat = 0.5

    // Chapter currently displayed (can change via "Next Chapter").
    @State private var activeChapterId = ""
    @State private var activeChapterTitle = ""
    @State private var didResume = false

    private var readingMode: ReadingMode {
        ReadingMode(rawValue: readingModeRaw) ?? .vertical
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            content

            if showControls {
                controlsOverlay
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle(activeChapterTitle.isEmpty ? chapterTitle : activeChapterTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation { showControls.toggle() }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .accessibilityLabel("Reader settings")
            }
        }
        .task(id: chapterId) {
            activeChapterId = chapterId
            activeChapterTitle = chapterTitle
            await viewModel.loadChapter(chapterId)
        }
        .onChange(of: viewModel.currentPage) { recordProgress() }
        .onChange(of: pageSelection) { _, newValue in
            if readingMode.isPaged { viewModel.currentPage = newValue }
        }
        .onAppear {
            // Keep the screen awake while reading; capture brightness to restore.
            UIApplication.shared.isIdleTimerDisabled = true
            if let screen = activeScreen {
                originalBrightness = screen.brightness
                brightness = Double(screen.brightness)
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            activeScreen?.brightness = originalBrightness
        }
    }

    // MARK: - Content states

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            centeredProgress
        } else if let errorMessage = viewModel.errorMessage {
            errorState(errorMessage)
        } else if viewModel.pages.isEmpty {
            emptyState
        } else {
            switch readingMode {
            case .vertical:
                verticalReader
            case .leftToRight, .rightToLeft:
                pagedReader
            }
        }
    }

    private var centeredProgress: some View {
        VStack { Spacer(); ProgressView("Loading pages..."); Spacer() }
    }

    private func errorState(_ message: String) -> some View {
        VStack {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.orange)
            Text("Error loading pages")
                .font(.headline)
                .padding(.top)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            Button("Retry") {
                Task { await viewModel.fetchChapterPages(chapterId: chapterId) }
            }
            .buttonStyle(.bordered)
            Spacer()
        }
        .padding()
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            Image(systemName: "book.closed")
                .font(.system(size: 50))
                .foregroundStyle(.gray)
            Text("No pages found")
                .font(.headline)
                .padding(.top)
            Spacer()
        }
    }

    // MARK: - Vertical reader (continuous scroll)

    private var verticalReader: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.offset) { index, pageURL in
                        KFImage(URL(string: pageURL))
                            .placeholder {
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 300)
                            }
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.02))
                            .cornerRadius(4)
                            .id(index)
                            .onAppear { viewModel.currentPage = index }
                    }

                    if let nextId = nextChapterId {
                        nextChapterButton(nextId)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
            }
            .background(Color(UIColor.systemBackground))
            .onAppear {
                guard !didResume else { return }
                if resumePage > 0, resumePage < viewModel.pages.count {
                    proxy.scrollTo(resumePage, anchor: .top)
                }
                didResume = true
            }
        }
    }

    // MARK: - Paged reader (LTR / RTL)

    private var pagedReader: some View {
        TabView(selection: $pageSelection) {
            ForEach(Array(viewModel.pages.enumerated()), id: \.offset) { index, pageURL in
                KFImage(URL(string: pageURL))
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFit()
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color(UIColor.systemBackground))
        // Flip swipe direction for right-to-left manga; page order stays logical.
        .environment(\.layoutDirection, readingMode == .rightToLeft ? .rightToLeft : .leftToRight)
        .onAppear {
            guard !didResume else { return }
            if resumePage > 0, resumePage < viewModel.pages.count {
                pageSelection = resumePage
                viewModel.currentPage = resumePage
            }
            didResume = true
        }
    }

    private func nextChapterButton(_ nextId: String) -> some View {
        Button {
            activeChapterId = nextId
            didResume = true
            Task { await viewModel.loadChapter(nextId) }
        } label: {
            HStack {
                Spacer()
                Text("Next Chapter").font(.headline)
                Image(systemName: "chevron.right")
                Spacer()
            }
            .padding()
            .background(Color.blue.opacity(0.15))
            .foregroundStyle(.blue)
            .cornerRadius(10)
        }
        .padding(.top, 16)
        .padding(.horizontal)
    }

    // MARK: - Controls overlay

    private var controlsOverlay: some View {
        VStack(spacing: 16) {
            Picker("Reading Mode", selection: $readingModeRaw) {
                ForEach(ReadingMode.allCases) { mode in
                    Label(mode.label, systemImage: mode.icon).tag(mode.rawValue)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 12) {
                Image(systemName: "sun.min")
                Slider(value: $brightness, in: 0...1)
                    .onChange(of: brightness) { _, newValue in
                        activeScreen?.brightness = CGFloat(newValue)
                    }
                Image(systemName: "sun.max")
            }
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding()
    }

    // MARK: - Helpers

    /// The screen backing the current window scene (replaces deprecated UIScreen.main).
    private var activeScreen: UIScreen? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .screen
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?
                .screen
    }

    /// Saves the current reading position to history (no-op without manga info).
    private func recordProgress() {
        guard let mangaId, let mangaTitle, !viewModel.pages.isEmpty else { return }
        ReadingHistoryStore.record(
            in: modelContext,
            mangaId: mangaId,
            mangaTitle: mangaTitle,
            coverURLString: coverURLString,
            chapterId: activeChapterId.isEmpty ? chapterId : activeChapterId,
            chapterTitle: activeChapterTitle.isEmpty ? chapterTitle : activeChapterTitle,
            currentPage: viewModel.currentPage,
            totalPages: viewModel.pages.count
        )
    }
}
