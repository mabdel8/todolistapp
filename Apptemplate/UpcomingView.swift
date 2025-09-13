//
//  UpcomingView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import SwiftData

struct UpcomingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTodos: [Todo]
    
    private var groupedTodos: [(String, [Todo])] {
        let upcomingTodos = allTodos.filter { 
            ($0.isToday || $0.isFuture) && $0.parentTodoId == nil 
        }
        let grouped = Dictionary(grouping: upcomingTodos) { todo in
            todo.formattedDate
        }
        
        return grouped.sorted { first, second in
            guard let firstTodo = first.value.first,
                  let secondTodo = second.value.first else { return false }
            return firstTodo.date < secondTodo.date
        }.map { (key, value) in
            (key, value.sorted { !$0.isCompleted && $1.isCompleted })
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if groupedTodos.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 60))
                                .foregroundStyle(.black.opacity(0.3))
                            
                            Text("No tasks scheduled")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Text("Add tasks for today or future dates")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
                        ForEach(groupedTodos, id: \.0) { date, todos in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(date.uppercased())
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 20)
                                
                                ForEach(todos) { todo in
                                    TodoRow(todo: todo)
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.top, 20)
                    }
                    
                    Spacer(minLength: 100) // Space for FAB
                }
            }
            .navigationTitle("Upcoming")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    UpcomingView()
        .modelContainer(for: Todo.self, inMemory: true)
}