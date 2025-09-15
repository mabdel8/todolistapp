//
//  AddTodoView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import SwiftData
import StoreKit

struct AddTodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeManager: StoreManager
    @Query private var allTodos: [Todo]
    
    @State private var title = ""
    @State private var date = Date()
    @State private var hasDeadline = false
    @State private var deadlineDate = Date()
    @State private var deadlineTime = Date()
    @State private var includeTime = false
    @State private var recurrencePattern: RecurrencePattern = .none
    @State private var parentTodoId: UUID?
    @State private var showPaywallAlert = false
    @State private var showPaywall = false
    
    var isSubtask: Bool = false
    var parentTodo: Todo?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What needs to be done?", text: $title)
                        .font(.body)
                }
                .listRowBackground(Color.clear)
                
                Section("When") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .tint(.black)
                }
                .listRowBackground(Color.clear)
                
                // Recurring - Now free for everyone
                if !isSubtask { // Don't show recurring for subtasks
                    Section("Repeat") {
                        Picker("Repeat", selection: $recurrencePattern) {
                            ForEach(RecurrencePattern.allCases, id: \.self) { pattern in
                                Text(pattern.displayName).tag(pattern)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.black)
                    }
                    .listRowBackground(Color.clear)
                }
                
                // Premium Features - Only Deadline
                if storeManager.isSubscribed {
                    Section("Premium Features") {
                        Toggle("Add Deadline", isOn: $hasDeadline)
                            .tint(.black)
                        
                        if hasDeadline {
                            DatePicker("Deadline Date", selection: $deadlineDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .tint(.black)
                            
                            Toggle("Include Time", isOn: $includeTime)
                                .tint(.black)
                            
                            if includeTime {
                                DatePicker("Deadline Time", selection: $deadlineTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.compact)
                                    .tint(.black)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                } else {
                    Section("Premium Features") {
                        Button(action: {
                            showPaywallAlert = true
                        }) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                Text("Add Deadline (Shows in Red)")
                                    .font(.body)
                                Spacer()
                                Text("Premium")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .foregroundStyle(.black)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle(isSubtask ? "New Subtask" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.black)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addTodo()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .disabled(title.isEmpty)
                }
            }
            .alert("Premium Feature", isPresented: $showPaywallAlert) {
                Button("Upgrade") {
                    showPaywall = true
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Upgrade to Premium to unlock deadlines")
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(isPresented: $showPaywall)
                    .environmentObject(storeManager)
            }
        }
    }
    
    private func addTodo() {
        // Create the main todo with recurring pattern (now free for all users)
        let pattern = !isSubtask ? recurrencePattern : .none
        let newTodo = Todo(title: title, date: date, recurrencePattern: pattern)
        
        if isSubtask, let parent = parentTodo {
            newTodo.parentTodoId = parent.id
        }
        
        if hasDeadline && storeManager.isSubscribed {
            let calendar = Calendar.current
            let deadlineDateComponents = calendar.dateComponents([.year, .month, .day], from: deadlineDate)
            
            if includeTime {
                let timeComponents = calendar.dateComponents([.hour, .minute], from: deadlineTime)
                if let combinedDeadline = calendar.date(from: DateComponents(
                    year: deadlineDateComponents.year,
                    month: deadlineDateComponents.month,
                    day: deadlineDateComponents.day,
                    hour: timeComponents.hour,
                    minute: timeComponents.minute
                )) {
                    newTodo.deadline = combinedDeadline
                }
            } else {
                // Just use the deadline date without specific time
                newTodo.deadline = deadlineDate
            }
        }
        
        // Check if this is the user's first task (excluding subtasks)
        let isFirstTask = allTodos.filter { $0.parentTodoId == nil }.isEmpty && !isSubtask
        
        modelContext.insert(newTodo)
        
        // Request review if this is the user's first task
        if isFirstTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                }
            }
        }
        
        dismiss()
    }
}

#Preview {
    AddTodoView()
        .environmentObject(StoreManager())
        .modelContainer(for: Todo.self, inMemory: true)
}