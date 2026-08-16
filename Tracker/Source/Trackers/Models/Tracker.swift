//
//  Tracker.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 29.05.2026.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    /// Дни недели повторения. У нерегулярного события расписания нет.
    let schedule: Set<WeekDay>
    /// Дата нерегулярного события. У привычки равна nil.
    let eventDate: Date?
    let isPinned: Bool
}

extension Tracker {
    /// Тип выводится из данных: событие хранит дату, привычка хранит расписание.
    var kind: TrackerKind {
        eventDate == nil ? .habit : .irregularEvent
    }

    /// Должен ли трекер отображаться на выбранный в календаре день.
    func isScheduled(on date: Date, calendar: Calendar = .current) -> Bool {
        if let eventDate {
            return calendar.isDate(eventDate, inSameDayAs: date)
        }

        guard let weekDay = WeekDay(date: date, calendar: calendar) else { return false }
        return schedule.contains(weekDay)
    }
}

enum WeekDay: Int, CaseIterable {
    case monday = 1
    case tuesday, wednesday,
         thursday, friday,
         saturday, sunday
}
