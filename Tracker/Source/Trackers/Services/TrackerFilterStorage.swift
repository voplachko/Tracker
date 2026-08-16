//
//  TrackerFilterStorage.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 05.08.2026.
//

import Foundation

/// Хранит выбранный пользователем фильтр трекеров между запусками приложения.
final class TrackerFilterStorage {

    private enum Key {
        static let selectedFilter = "selectedTrackerFilter"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var selectedFilter: TrackerFilter {
        get {
            guard
                let rawValue = userDefaults.object(forKey: Key.selectedFilter) as? Int,
                let filter = TrackerFilter(rawValue: rawValue)
            else {
                return .allTrackers
            }
            return filter
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Key.selectedFilter)
        }
    }
}
