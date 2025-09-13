//
//  Todo.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import Foundation
import SwiftData

enum RecurrencePattern: String, CaseIterable, Codable {
    case none = "none"
    case daily = "daily"
    case weekdays = "weekdays"        // Monday to Friday
    case weekly = "weekly"
    case biweekly = "biweekly"       // Every 2 weeks
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .none: return "None"
        case .daily: return "Every day"
        case .weekdays: return "Weekdays"
        case .weekly: return "Every week"
        case .biweekly: return "Every 2 weeks"
        case .monthly: return "Every month"
        case .yearly: return "Every year"
        }
    }
    
    var shortName: String {
        switch self {
        case .none: return ""
        case .daily: return "Daily"
        case .weekdays: return "Weekdays"
        case .weekly: return "Weekly"
        case .biweekly: return "Biweekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}

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
    var recurrencePattern: RecurrencePattern // Recurring pattern (premium)
    var originalId: UUID? // Links back to the original recurring task
    
    init(title: String, date: Date = Date(), isCompleted: Bool = false, recurrencePattern: RecurrencePattern = .none) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.deadline = nil
        self.parentTodoId = nil
        self.recurrencePattern = recurrencePattern
        self.originalId = nil
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
    
    // Recurring task properties
    var isRecurring: Bool {
        recurrencePattern != .none
    }
    
    var hasRecurrenceIcon: Bool {
        isRecurring && parentTodoId == nil // Only show on parent tasks
    }
    
    // Calculate next occurrence date based on recurrence pattern
    func nextOccurrenceDate() -> Date? {
        guard recurrencePattern != .none else { return nil }
        
        let calendar = Calendar.current
        
        switch recurrencePattern {
        case .none:
            return nil
            
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date)
            
        case .weekdays:
            let weekday = calendar.component(.weekday, from: date)
            if weekday == 6 { // Friday
                return calendar.date(byAdding: .day, value: 3, to: date) // Next Monday
            } else if weekday == 7 { // Saturday (edge case)
                return calendar.date(byAdding: .day, value: 2, to: date) // Next Monday
            } else {
                return calendar.date(byAdding: .day, value: 1, to: date) // Next weekday
            }
            
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
            
        case .biweekly:
            return calendar.date(byAdding: .weekOfYear, value: 2, to: date)
            
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date)
            
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date)
        }
    }
}