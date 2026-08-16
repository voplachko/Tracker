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

    enum PlaceholderState {
        case hidden
        case noTrackers
        case nothingFound
    }

    var onDataChanged: (() -> Void)?
    var onPlaceholderStateChanged: Binding<PlaceholderState>?
    var onFiltersButtonVisibilityChanged: Binding<Bool>?
    var onDateChanged: Binding<Date>?

    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private let filterStorage: TrackerFilterStorage

    private let pinnedSectionTitle = L10n.Trackers.pinnedSection

    private(set) var selectedDate = Date()
    private var searchQuery = ""
    private var sections: [Section] = []
    private var completedRecords: [TrackerRecord] = []
    private var categoryTitleByTrackerId: [UUID: String] = [:]
    private var hasTrackersOnSelectedDate = false

    init(
        categoryStore: TrackerCategoryStore,
        recordStore: TrackerRecordStore,
        filterStorage: TrackerFilterStorage = TrackerFilterStorage(),
        selectedDate: Date = Date()
    ) {
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        self.filterStorage = filterStorage
        self.selectedDate = selectedDate
        self.categoryStore.delegate = self
        self.recordStore.delegate = self
    }

    var currentFilter: TrackerFilter {
        filterStorage.selectedFilter
    }

    func viewDidLoad() {
        reload()
    }

    func setDate(_ date: Date) {
        selectedDate = date
        reload()
    }

    func setFilter(_ filter: TrackerFilter) {
        switch filter {
        case .today:
            // «Трекеры на сегодня» сбрасывает фильтрацию и переводит календарь на сегодня
            filterStorage.selectedFilter = .allTrackers
            selectedDate = Date()
            onDateChanged?(selectedDate)
        case .allTrackers, .completed, .uncompleted:
            filterStorage.selectedFilter = filter
        }
        reload()
    }

    func setSearchQuery(_ query: String?) {
        let newQuery = (query ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard newQuery != searchQuery else { return }

        searchQuery = newQuery
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
        onPlaceholderStateChanged?(placeholderState())
        onFiltersButtonVisibilityChanged?(hasTrackersOnSelectedDate)
        onDataChanged?()
    }

    private func placeholderState() -> PlaceholderState {
        guard sections.isEmpty else { return .hidden }
        let isFiltering = !searchQuery.isEmpty || currentFilter.isActive
        return isFiltering ? .nothingFound : .noTrackers
    }

    private func makeSections(for date: Date) -> [Section] {
        categoryTitleByTrackerId = [:]
        hasTrackersOnSelectedDate = false

        let categories = (try? categoryStore.categories()) ?? []

        var pinned: [Tracker] = []
        var categorySections: [Section] = []

        for category in categories {
            let scheduled = category.trackers.filter { $0.isScheduled(on: date) }
            if !scheduled.isEmpty {
                hasTrackersOnSelectedDate = true
            }

            let visible = scheduled.filter { matchesSearch($0) && matchesFilter($0) }
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

    private func matchesSearch(_ tracker: Tracker) -> Bool {
        guard !searchQuery.isEmpty else { return true }
        return tracker.title.localizedCaseInsensitiveContains(searchQuery)
    }

    private func matchesFilter(_ tracker: Tracker) -> Bool {
        switch currentFilter {
        case .allTrackers, .today: return true
        case .completed: return isCompleted(tracker)
        case .uncompleted: return !isCompleted(tracker)
        }
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
