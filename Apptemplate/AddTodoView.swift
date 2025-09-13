//
//  AddTodoView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import SwiftData

struct AddTodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeManager: StoreManager
    
    @State private var title = ""
    @State private var date = Date()
    @State private var hasDeadline = false
    @State private var deadlineDate = Date()
    @State private var deadlineTime = Date()
    @State private var includeTime = false
    @State private var parentTodoId: UUID?
    @State private var showPaywallAlert = false
    
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
                
                if storeManager.isSubscribed {
                    Section("Deadline (Premium)") {
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
                    Section {
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
                    dismiss()
                    // The parent view will show the paywall
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Upgrade to Premium to add deadlines that show in red when overdue")
            }
        }
    }
    
    private func addTodo() {
        let newTodo = Todo(title: title, date: date)
        
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
        
        modelContext.insert(newTodo)
        dismiss()
    }
}

#Preview {
    AddTodoView()
        .environmentObject(StoreManager())
        .modelContainer(for: Todo.self, inMemory: true)
}