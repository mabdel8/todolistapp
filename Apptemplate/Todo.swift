//
//  Todo.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import Foundation
import SwiftData

@Model
final class Todo {
    var id: UUID
    var title: String
    var date: Date // The date this task is scheduled for
    var isCompleted: Bool
    var createdAt: Date
    
    // Premium features
    var deadline: Date? // Optional deadline date/time (shows in red)
    var parentTodoId: UUID? // For subtasks
    
    init(title: String, date: Date = Date(), isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.deadline = nil
        self.parentTodoId = nil
    }
    
    // Computed properties
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var isFuture: Bool {
        date > Date() && !isToday
    }
    
    var isOverdue: Bool {
        // Check if deadline is overdue (for premium users)
        if let deadline = deadline {
            return !isCompleted && deadline < Date()
        }
        // For non-premium, check if date is in the past
        return !isCompleted && date < Date() && !isToday
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        if isToday {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    var formattedDeadline: String? {
        guard let deadline = deadline else { return nil }
        let formatter = DateFormatter()
        
        // Check if deadline includes time or is just a date
        let calendar = Calendar.current
        let deadlineComponents = calendar.dateComponents([.hour, .minute], from: deadline)
        
        if deadlineComponents.hour == 0 && deadlineComponents.minute == 0 {
            // Just a date, no specific time
            formatter.dateFormat = "MMM d"
        } else {
            // Has specific time
            if calendar.isDate(deadline, inSameDayAs: date) {
                formatter.dateFormat = "h:mm a"
            } else {
                formatter.dateFormat = "MMM d, h:mm a"
            }
        }
        
        return formatter.string(from: deadline)
    }
}