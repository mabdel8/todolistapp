//
//  TodayView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTodos: [Todo]
    
    private var todayTodos: [Todo] {
        allTodos.filter { $0.isToday && $0.parentTodoId == nil }
            .sorted { !$0.isCompleted && $1.isCompleted }
    }
    
    private var overdueTodos: [Todo] {
        allTodos.filter { $0.isOverdue && $0.parentTodoId == nil }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !overdueTodos.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("OVERDUE")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            
                            ForEach(overdueTodos) { todo in
                                TodoRow(todo: todo)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    
                    if todayTodos.isEmpty && overdueTodos.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 60))
                                .foregroundStyle(.black.opacity(0.3))
                            
                            Text("No tasks for today")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Text("Tap + to add a new task")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            if !overdueTodos.isEmpty && !todayTodos.isEmpty {
                                Text("TODAY")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 20)
                            }
                            
                            ForEach(todayTodos) { todo in
                                TodoRow(todo: todo)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, overdueTodos.isEmpty ? 20 : 0)
                    }
                    
                    Spacer(minLength: 100) // Space for FAB
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: Todo.self, inMemory: true)
}