//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 24.06.2026.
//

import UIKit

final class TrackersViewModel {

    private struct Section {
        let title: String
        let trackers: [Tracker]
    }

    var onDataChanged: (() -> Void)?
    var onPlaceholderVisibilityChanged: Binding<Bool>?

    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore

    private let pinnedSectionTitle = "Закреплённые"

    private(set) var selectedDate = Date()
    private var sections: [Section] = []
    private var completedRecords: [TrackerRecord] = []
    private var categoryTitleByTrackerId: [UUID: String] = [:]

    init(categoryStore: TrackerCategoryStore, recordStore: TrackerRecordStore) {
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        self.categoryStore.delegate = self
        self.recordStore.delegate = self
    }

    func viewDidLoad() {
        reload()
    }

    func setDate(_ date: Date) {
        selectedDate = date
        reload()
    }

    func numberOfSections() -> Int {
        sections.count
    }

    func numberOfItems(in section: Int) -> Int {
        sections[section].trackers.count
    }

    func categoryTitle(in section: Int) -> String {
        sections[section].title
    }

    func tracker(at indexPath: IndexPath) -> Tracker {
        sections[indexPath.section].trackers[indexPath.item]
    }

    func cellModel(at indexPath: IndexPath) -> TrackerCellModel {
        let tracker = tracker(at: indexPath)
        return TrackerCellModel(
            tracker: tracker,
            isCompleted: isCompleted(tracker),
            completionCount: totalCompletions(for: tracker),
            date: selectedDate
        )
    }

    func isPinned(at indexPath: IndexPath) -> Bool {
        tracker(at: indexPath).isPinned
    }

    func editingContext(at indexPath: IndexPath) -> (tracker: Tracker, categoryTitle: String, daysCount: Int) {
        let tracker = tracker(at: indexPath)
        let categoryTitle = categoryTitleByTrackerId[tracker.id] ?? ""
        return (tracker, categoryTitle, totalCompletions(for: tracker))
    }

    func toggleCompletion(for tracker: Tracker) {
        guard !Calendar.current.isDateInFuture(selectedDate) else { return }

        let day = Calendar.current.startOfDay(for: selectedDate)
        let record = TrackerRecord(trackerId: tracker.id, date: day)

        if isCompleted(tracker) {
            try? recordStore.removeRecord(record)
        } else {
            try? recordStore.addRecord(record)
        }
        reload()
    }

    func togglePin(at indexPath: IndexPath) {
        let tracker = tracker(at: indexPath)
        try? categoryStore.setPinned(!tracker.isPinned, forTrackerWithId: tracker.id)
        reload()
    }

    func deleteTracker(at indexPath: IndexPath) {
        let tracker = tracker(at: indexPath)
        try? categoryStore.deleteTracker(withId: tracker.id)
        reload()
    }

    func addTracker(_ tracker: Tracker, categoryTitle: String) {
        try? categoryStore.addTracker(tracker, toCategoryWithTitle: categoryTitle)
        reload()
    }

    func updateTracker(_ tracker: Tracker, categoryTitle: String) {
        try? categoryStore.updateTracker(tracker, toCategoryWithTitle: categoryTitle)
        reload()
    }

    // MARK: - Private

    private func reload() {
        completedRecords = (try? recordStore.records()) ?? []
        sections = makeSections(for: selectedDate)
        onPlaceholderVisibilityChanged?(sections.isEmpty)
        onDataChanged?()
    }

    private func makeSections(for date: Date) -> [Section] {
        categoryTitleByTrackerId = [:]

        guard let selectedWeekDay = WeekDay(date: date) else { return [] }

        let categories = (try? categoryStore.categories()) ?? []

        var pinned: [Tracker] = []
        var categorySections: [Section] = []

        for category in categories {
            let visible = category.trackers.filter { $0.schedule.contains(selectedWeekDay) }
            for tracker in visible {
                categoryTitleByTrackerId[tracker.id] = category.title
            }

            pinned.append(contentsOf: visible.filter { $0.isPinned })

            let unpinned = visible.filter { !$0.isPinned }
            if !unpinned.isEmpty {
                categorySections.append(Section(title: category.title, trackers: unpinned))
            }
        }

        var result: [Section] = []
        if !pinned.isEmpty {
            result.append(Section(title: pinnedSectionTitle, trackers: pinned))
        }
        result.append(contentsOf: categorySections)
        return result
    }

    private func totalCompletions(for tracker: Tracker) -> Int {
        completedRecords.filter { $0.trackerId == tracker.id }.count
    }

    private func isCompleted(_ tracker: Tracker) -> Bool {
        let day = Calendar.current.startOfDay(for: selectedDate)
        return completedRecords.contains {
            $0.trackerId == tracker.id && Calendar.current.startOfDay(for: $0.date) == day
        }
    }
}

// MARK: - Store delegates

extension TrackersViewModel: TrackerCategoryStoreDelegate {
    func categoryStoreDidChange() {
        reload()
    }
}

extension TrackersViewModel: TrackerRecordStoreDelegate {
    func recordStoreDidChange() {
        reload()
    }
}
