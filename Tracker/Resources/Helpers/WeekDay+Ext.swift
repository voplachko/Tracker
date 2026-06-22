//
//  WeekDay+Ext.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 01.06.2026.
//

import Foundation

extension WeekDay {
    init?(date: Date, calendar: Calendar = .current) {
        switch calendar.component(.weekday, from: date) {
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        case 1: self = .sunday
        default: return nil
        }
    }
}

extension WeekDay {
    var title: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }

    var shortTitle: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}

extension WeekDay {
    static func encode(_ days: Set<WeekDay>) -> String {
        WeekDay.allCases
            .filter { days.contains($0) }
            .map { String($0.rawValue) }
            .joined(separator: ",")
    }

    static func decode(_ string: String) -> Set<WeekDay> {
        let days = string
            .split(separator: ",")
            .compactMap { Int($0) }
            .compactMap { WeekDay(rawValue: $0) }
        return Set(days)
    }
}
