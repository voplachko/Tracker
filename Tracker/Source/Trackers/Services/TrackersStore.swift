//
//  TrackersStore.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 29.05.2026.
//

import UIKit

final class TrackersStore {
    private(set) var categories: [TrackerCategory] = []
    private(set) var completedTrackers: [TrackerRecord] = []

    func addTracker(_ tracker: Tracker, toCategoryWithTitle categoryTitle: String) {
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
            let category = categories[index]
            let updatedCategory = TrackerCategory(
                title: category.title,
                trackers: category.trackers + [tracker]
            )

            categories = categories.enumerated().map { currentIndex, category in
                currentIndex == index ? updatedCategory : category
            }
        } else {
            let newCategory = TrackerCategory(
                title: categoryTitle,
                trackers: [tracker]
            )

            categories = categories + [newCategory]
        }
    }

    func markTrackerCompleted(_ tracker: Tracker, on date: Date) {
        let completedDate = Calendar.current.startOfDay(for: date)

        guard !isTrackerCompleted(tracker, on: completedDate) else { return }

        let record = TrackerRecord(
            trackerId: tracker.id,
            date: completedDate
        )

        completedTrackers = completedTrackers + [record]
    }

    func unmarkTrackerCompleted(_ tracker: Tracker, on date: Date) {
        let completedDate = Calendar.current.startOfDay(for: date)

        completedTrackers = completedTrackers.filter { record in
            !(record.trackerId == tracker.id && record.date == completedDate)
        }
    }

    func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        let completedDate = Calendar.current.startOfDay(for: date)

        return completedTrackers.contains { record in
            record.trackerId == tracker.id && record.date == completedDate
        }
    }
}
