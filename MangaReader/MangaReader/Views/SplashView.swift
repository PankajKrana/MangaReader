//
//  SplashView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var scaleEffect: CGFloat = 0.6
    @State private var opacity: Double = 0.0
    
    var body: some View {
        if isActive {
            MainView()
        } else {
            ZStack {
                Image("CoverImage")
                    .scaledToFit()
                
                
                VStack {
                    Image(systemName: "book.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .scaleEffect(scaleEffect)
                        .opacity(opacity)
                    
                    Text("MangaReader")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.top, 16)
                        .opacity(opacity)
                }
            }
            .onAppear {
                withAnimation(.easeIn(duration: 0.8)) {
                    self.scaleEffect = 1.0
                    self.opacity = 1.0
                }
                
                // Show splash for 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
