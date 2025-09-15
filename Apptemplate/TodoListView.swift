//
//  TodoListView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import SwiftData

struct TodoListView: View {
    @EnvironmentObject var storeManager: StoreManager
    @State private var selectedTab = 0
    @State private var showAddTodo = false
    @State private var showPaywall = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TodayView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                    }
                    .tag(0)
                
                UpcomingView()
                    .tabItem {
                        Image(systemName: "calendar")
                    }
                    .tag(1)
                
                if storeManager.isSubscribed {
                    CalendarView()
                        .tabItem {
                            Image(systemName: "calendar.badge.clock")
                        }
                        .tag(2)
                } else {
                    LockedCalendarView(showPaywall: $showPaywall)
                        .tabItem {
                            Image(systemName: "lock.fill")
                        }
                        .tag(2)
                }
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                    }
                    .tag(3)
            }
            .tint(.black)
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton {
                        showAddTodo = true
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showAddTodo) {
            AddTodoView()
                .environmentObject(storeManager)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(isPresented: $showPaywall)
                .environmentObject(storeManager)
        }
    }
}

struct LockedCalendarView: View {
    @Binding var showPaywall: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundStyle(.black)
            
            VStack(spacing: 10) {
                Text("Calendar View")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Upgrade to Premium to unlock calendar view with all your todos")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                showPaywall = true
            }) {
                Text("Unlock Premium")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 200)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
    }
}

#Preview {
    TodoListView()
        .environmentObject(StoreManager())
        .modelContainer(for: Todo.self, inMemory: true)
}