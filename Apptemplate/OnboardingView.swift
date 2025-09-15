//
//  OnboardingView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var showContent = false
    @State private var laurelScale: CGFloat = 0.8
    @State private var logoScale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            
            // App Logo with shadow
            Image("applogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .scaleEffect(logoScale)
                .opacity(showContent ? 1 : 0)
            
            // Main Content
            VStack(spacing: 40) {
                // Title and subtitle
                VStack(spacing: 20) {
                    Text("Minimal Todo")
                        .font(.system(size: 34, weight: .bold, design: .default))
                        .foregroundStyle(.primary)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: showContent)
                    
                    Text("Simple. Clean. Focused.")
                        .font(.system(size: 20, weight: .medium, design: .default))
                        .foregroundStyle(.primary)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.3), value: showContent)
                    
//                    Text("Get things done without the clutter.")
//                        .font(.system(size: 18, weight: .regular, design: .default))
//                        .foregroundStyle(.secondary)
//                        .multilineTextAlignment(.center)
//                        .opacity(showContent ? 1 : 0)
//                        .animation(.easeOut(duration: 0.8).delay(0.4), value: showContent)
                }
                .padding(.horizontal, 40)
                
                
                // Feature list (only first two)
                VStack(alignment: .leading, spacing: 20) {
                    FeatureItem(icon: "checkmark.circle", text: "Create and manage tasks")
                    FeatureItem(icon: "calendar", text: "View today and upcoming todos")
                }
                .padding(.horizontal, 40)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.8), value: showContent)
                
                // Centered Laurel testimonial section
                LaurelTestimonialView()
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(laurelScale)
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: showContent)
            }
            
            Spacer()
            
            // Get Started Button
            Button(action: {
                hasCompletedOnboarding = true
            }) {
                Text("Get Started")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
            .opacity(showContent ? 1 : 0)
            .scaleEffect(showContent ? 1 : 0.8)
            .animation(.easeOut(duration: 0.8).delay(1.0), value: showContent)
        }
        .background(Color(.systemBackground))
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.8)) {
            showContent = true
            logoScale = 1.0
            laurelScale = 1.0
        }
    }
}

struct LaurelTestimonialView: View {
    var body: some View {
        ZStack {
            // Centered laurel images
            HStack(spacing: 0) {
                Image("leftlaurel")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
                
                Spacer()
                    .frame(width: 100) // Space for text in center
                
                Image("rightlaurel")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
            }
            
            // Centered testimonial text
            VStack(spacing: 6) {
//                HStack(spacing: 3) {
//                    ForEach(0..<5, id: \.self) { _ in
//                        Image(systemName: "star.fill")
//                            .font(.system(size: 12))
//                            .foregroundStyle(.black)
//                    }
//                }
                Text("Trusted by")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundStyle(.black)
                Text("Thousands")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundStyle(.black)
                
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(maxWidth: 280)
    }
}

struct FeatureItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(.black)
                .frame(width: 28)
            
            Text(text)
                .font(.system(size: 17, weight: .regular, design: .default))
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
