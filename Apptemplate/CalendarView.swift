//
//  CalendarView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTodos: [Todo]
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    private var calendar = Calendar.current
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var daysInMonth: [Date] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        let previousMonthDays = firstWeekday
        
        var days: [Date] = []
        
        // Add empty days for previous month
        for _ in 0..<previousMonthDays {
            days.append(Date.distantPast)
        }
        
        // Add days of current month
        for day in 1...monthRange.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func todosForDate(_ date: Date) -> [Todo] {
        allTodos.filter { todo in
            todo.parentTodoId == nil &&
            calendar.isDate(todo.date, inSameDayAs: date)
        }
    }
    
    private var selectedDateTodos: [Todo] {
        todosForDate(selectedDate).sorted { !$0.isCompleted && $1.isCompleted }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month navigation
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundStyle(.black)
                    }
                    
                    Spacer()
                    
                    Text(monthYearString)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundStyle(.black)
                    }
                }
                .padding()
                
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
                    // Weekday headers
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    
                    // Days
                    ForEach(daysInMonth, id: \.self) { date in
                        if date == Date.distantPast {
                            Color.clear
                                .frame(height: 44)
                        } else {
                            DayCell(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                isToday: calendar.isDateInToday(date),
                                todoCount: todosForDate(date).count,
                                hasIncompleteTodos: todosForDate(date).contains { !$0.isCompleted }
                            ) {
                                selectedDate = date
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.top)
                
                // Selected date todos
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(formatSelectedDate())
                                .font(.headline)
                            Spacer()
                            if !selectedDateTodos.isEmpty {
                                Text("\(selectedDateTodos.count) task\(selectedDateTodos.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        if selectedDateTodos.isEmpty {
                            Text("No tasks for this date")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                        } else {
                            ForEach(selectedDateTodos) { todo in
                                TodoRow(todo: todo)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer(minLength: 100) // Space for FAB
                    }
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func previousMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        if calendar.isDateInToday(selectedDate) {
            return "Today"
        } else if calendar.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else {
            formatter.dateFormat = "EEEE, MMMM d"
            return formatter.string(from: selectedDate)
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let todoCount: Int
    let hasIncompleteTodos: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16))
                    .fontWeight(isToday ? .semibold : .regular)
                    .foregroundStyle(isSelected ? .white : (isToday ? .black : .primary))
                
                if todoCount > 0 {
                    Circle()
                        .fill(hasIncompleteTodos ? 
                              (isSelected ? Color.white : Color.black) : 
                              (isSelected ? Color.white.opacity(0.5) : Color.black.opacity(0.3)))
                        .frame(width: 4, height: 4)
                } else {
                    Color.clear
                        .frame(width: 4, height: 4)
                }
            }
            .frame(width: 44, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.black : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday && !isSelected ? Color.black : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CalendarView()
        .environmentObject(StoreManager())
        .modelContainer(for: Todo.self, inMemory: true)
}