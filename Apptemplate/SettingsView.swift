//
//  SettingsView.swift
//  Apptemplate
//
//  Created by Claude on 9/13/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var storeManager: StoreManager
    @State private var showPaywall = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Subscription") {
                    if storeManager.isSubscribed {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Premium Active")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    } else {
                        Button(action: {
                            showPaywall = true
                        }) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.yellow)
                                Text("Upgrade to Premium")
                                    .foregroundStyle(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://abdalla2024.github.io/todo/privacy.html")!) {
                        HStack {
                            Text("Privacy Policy")
                                .foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://abdalla2024.github.io/todo/terms.html")!) {
                        HStack {
                            Text("Terms of Service")
                                .foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listRowBackground(Color.clear)
                
                Section("Support") {
                    Link(destination: URL(string: "https://abdalla2024.github.io/todo/")!) {
                        HStack {
                            Text("Contact Support")
                                .foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if storeManager.isSubscribed {
                        Button(action: {
                            Task {
                                await storeManager.restorePurchases()
                            }
                        }) {
                            Text("Restore Purchases")
                                .foregroundStyle(.black)
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(isPresented: $showPaywall)
                .environmentObject(storeManager)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(StoreManager())
}
