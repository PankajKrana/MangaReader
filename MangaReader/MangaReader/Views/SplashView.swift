//
//  SplashView.swift
//  MangaReader
//
//  Created by Pankaj Kumar Rana on 8/23/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var scaleEffect: CGFloat = 0.3
    @State private var opacity: Double = 0.0
    @State private var rotationAngle: Double = 0
    @State private var backgroundOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 50
    
    var body: some View {
        if isActive {
            MainView()
        } else {
            ZStack {
                // Animated background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.8),
                        Color.purple.opacity(0.6),
                        Color.pink.opacity(0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .opacity(backgroundOpacity)
                
                // Background pattern
                VStack {
                    ForEach(0..<8, id: \.self) { row in
                        HStack {
                            ForEach(0..<6, id: \.self) { col in
                                Image(systemName: "book.closed")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.1))
                                    .rotationEffect(.degrees(Double(row * col) * 15))
                            }
                        }
                    }
                }
                .opacity(backgroundOpacity)
                .scaleEffect(1.5)
                
                VStack(spacing: 24) {
                    // App icon with animations
                    ZStack {
                        // Background circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 140, height: 140)
                            .scaleEffect(scaleEffect)
                            .opacity(opacity)
                        
                        // Main icon
                        Image(systemName: "book.fill")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)
                            .scaleEffect(scaleEffect)
                            .opacity(opacity)
                            .rotationEffect(.degrees(rotationAngle))
                        
                        // Decorative elements
                        ForEach(0..<8, id: \.self) { index in
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .offset(x: 80)
                                .rotationEffect(.degrees(Double(index) * 45 + rotationAngle))
                                .scaleEffect(scaleEffect)
                                .opacity(opacity)
                        }
                    }
                    
                    // App name and tagline
                    VStack(spacing: 8) {
                        Text("MangaReader")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(opacity)
                            .offset(y: titleOffset)
                        
                        Text("Discover • Read • Enjoy")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .opacity(opacity * 0.8)
                            .offset(y: titleOffset)
                    }
                    
                    // Loading indicator
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 10, height: 10)
                                .scaleEffect(scaleEffect)
                                .opacity(opacity)
                                .animation(
                                    .easeInOut(duration: 0.8)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: scaleEffect
                                )
                        }
                    }
                    .padding(.top, 30)
                }
            }
            .onAppear {
                startAnimations()
                
                // Navigate to main view after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        self.isActive = true
                    }
                }
            }
        }
    }
    
    private func startAnimations() {
        // Background animation
        withAnimation(.easeIn(duration: 1.0)) {
            backgroundOpacity = 1.0
        }
        
        // Main icon animation
        withAnimation(.spring(response: 1.0, dampingFraction: 0.6, blendDuration: 0)) {
            scaleEffect = 1.0
            opacity = 1.0
        }
        
        // Title animation
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            titleOffset = 0
        }
        
        // Rotation animation
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
}

#Preview {
    SplashView()
}
