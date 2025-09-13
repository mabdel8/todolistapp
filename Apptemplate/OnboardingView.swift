//
//  OnboardingView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: "checklist")
                .font(.system(size: 100))
                .foregroundStyle(.black)
            
            VStack(spacing: 20) {
                Text("Minimal Todo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Simple. Clean. Focused.\nGet things done without the clutter.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 40)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                FeatureItem(icon: "checkmark.circle", text: "Create and manage tasks")
                FeatureItem(icon: "calendar", text: "View today and upcoming todos")
                FeatureItem(icon: "lock.fill", text: "Premium: Calendar, Subtasks & Deadlines")
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: {
                hasCompletedOnboarding = true
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct FeatureItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.black)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}