//
//  TrackerFilter.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 05.08.2026.
//

import Foundation

enum TrackerFilter: Int, CaseIterable {
    case allTrackers
    case today
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .allTrackers: return L10n.Filters.all
        case .today: return L10n.Filters.today
        case .completed: return L10n.Filters.completed
        case .uncompleted: return L10n.Filters.uncompleted
        }
    }

    /// «Все трекеры» и «Трекеры на сегодня» возвращают список к стандартному
    /// состоянию, поэтому активным фильтром не считаются.
    var isActive: Bool {
        switch self {
        case .allTrackers, .today: return false
        case .completed, .uncompleted: return true
        }
    }
}
