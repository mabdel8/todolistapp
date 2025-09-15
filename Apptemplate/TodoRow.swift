//
//  TodoRow.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import SwiftData

struct TodoRow: View {
    @Bindable var todo: Todo
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var storeManager: StoreManager
    @Query private var allTodos: [Todo]
    @State private var showSubtasks = false
    @State private var showAddSubtask = false
    @State private var showPaywallAlert = false
    
    private var subtasks: [Todo] {
        allTodos.filter { $0.parentTodoId == todo.id }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Checkbox
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        completeTodo()
                    }
                }) {
                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundStyle(todo.isCompleted ? .black.opacity(0.6) : .black)
                }
                
                // Title and info
                VStack(alignment: .leading, spacing: 4) {
                    Text(todo.title)
                        .font(.body)
                        .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                        .strikethrough(todo.isCompleted, color: .secondary)
                    
                    HStack(spacing: 8) {
                        if !todo.isToday {
                            Text(todo.formattedDate)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if todo.hasRecurrenceIcon {
                            HStack(spacing: 2) {
                                Image(systemName: "repeat")
                                    .font(.caption2)
                                Text(todo.recurrencePattern.shortName)
                                    .font(.caption)
                            }
                            .foregroundStyle(.black.opacity(0.7))
                        }
                        
                        if let deadline = todo.formattedDeadline {
                            HStack(spacing: 2) {
//                                Image(systemName: "exclamationmark.triangle.fill")
//                                    .font(.caption2)
                                Text("Due: \(deadline)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(todo.isCompleted ? Color.secondary : (todo.isOverdue ? Color.red : Color.red.opacity(0.7)))
                        }
                        
                        if !subtasks.isEmpty {
                            Text("\(subtasks.filter { $0.isCompleted }.count)/\(subtasks.count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Actions
                if storeManager.isSubscribed && todo.parentTodoId == nil {
                    Menu {
                        Button(action: {
                            showAddSubtask = true
                        }) {
                            Label("Add Subtask", systemImage: "plus.circle")
                        }
                        
                        if !subtasks.isEmpty {
                            Button(action: {
                                withAnimation {
                                    showSubtasks.toggle()
                                }
                            }) {
                                Label(showSubtasks ? "Hide Subtasks" : "Show Subtasks", 
                                      systemImage: showSubtasks ? "chevron.up" : "chevron.down")
                            }
                        }
                        
                        Button(role: .destructive, action: {
                            deleteTodo()
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                    }
                } else if todo.parentTodoId == nil {
                    // Free user - show locked subtask option
                    Menu {
                        Button(action: {
                            showPaywallAlert = true
                        }) {
                            Label("Add Subtask (Premium)", systemImage: "lock.fill")
                        }
                        
                        Button(role: .destructive, action: {
                            deleteTodo()
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                    }
                }
            }
            
            // Subtasks
            if showSubtasks && !subtasks.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(subtasks) { subtask in
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(Color.black.opacity(0.2))
                                .frame(width: 2, height: 20)
                                .padding(.leading, 11)
                            
                            TodoRow(todo: subtask)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .sheet(isPresented: $showAddSubtask) {
            AddTodoView(isSubtask: true, parentTodo: todo)
                .environmentObject(storeManager)
        }
        .alert("Premium Feature", isPresented: $showPaywallAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Upgrade to Premium to create subtasks")
        }
    }
    
    private func completeTodo() {
        todo.isCompleted.toggle()
        
        // If this is a recurring task being completed (not uncompleted)
        if todo.isCompleted && todo.isRecurring && todo.parentTodoId == nil {
            createNextOccurrence()
        }
    }
    
    private func createNextOccurrence() {
        guard let nextDate = todo.nextOccurrenceDate() else { return }
        
        // Create the next occurrence
        let nextTodo = Todo(
            title: todo.title,
            date: nextDate,
            recurrencePattern: todo.recurrencePattern
        )
        
        // Copy deadline if it exists (adjust for the new date)
        if let originalDeadline = todo.deadline {
            let calendar = Calendar.current
            let timeInterval = originalDeadline.timeIntervalSince(todo.date)
            nextTodo.deadline = nextDate.addingTimeInterval(timeInterval)
        }
        
        // Link to original for tracking
        nextTodo.originalId = todo.originalId ?? todo.id
        
        modelContext.insert(nextTodo)
    }
    
    private func deleteTodo() {
        // Delete all subtasks first
        for subtask in subtasks {
            modelContext.delete(subtask)
        }
        // Delete the todo
        modelContext.delete(todo)
    }
}

#Preview {
    TodoRow(todo: Todo(title: "Sample Task"))
        .environmentObject(StoreManager())
        .modelContainer(for: Todo.self, inMemory: true)
        .padding()
}
