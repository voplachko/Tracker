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
        case .monday: return L10n.WeekDay.monday
        case .tuesday: return L10n.WeekDay.tuesday
        case .wednesday: return L10n.WeekDay.wednesday
        case .thursday: return L10n.WeekDay.thursday
        case .friday: return L10n.WeekDay.friday
        case .saturday: return L10n.WeekDay.saturday
        case .sunday: return L10n.WeekDay.sunday
        }
    }

    var shortTitle: String {
        switch self {
        case .monday: return L10n.WeekDay.Short.monday
        case .tuesday: return L10n.WeekDay.Short.tuesday
        case .wednesday: return L10n.WeekDay.Short.wednesday
        case .thursday: return L10n.WeekDay.Short.thursday
        case .friday: return L10n.WeekDay.Short.friday
        case .saturday: return L10n.WeekDay.Short.saturday
        case .sunday: return L10n.WeekDay.Short.sunday
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
