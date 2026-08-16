//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 24.06.2026.
//

import Foundation

final class StatisticsViewModel {

    let screenTitle = L10n.Statistics.title

    var onStatisticsChanged: Binding<[StatisticItem]>?
    var onPlaceholderVisibilityChanged: Binding<Bool>?

    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private let calendar: Calendar

    init(
        categoryStore: TrackerCategoryStore,
        recordStore: TrackerRecordStore,
        calendar: Calendar = .current
    ) {
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        self.calendar = calendar
    }

    /// Показатели пересчитываются при каждом появлении экрана:
    /// пользователь мог отметить или удалить трекер на главном.
    func viewWillAppear() {
        reload()
    }

    // MARK: - Private

    private func reload() {
        let records = (try? recordStore.records()) ?? []
        let trackers = ((try? categoryStore.categories()) ?? []).flatMap { $0.trackers }

        guard !records.isEmpty else {
            onPlaceholderVisibilityChanged?(true)
            onStatisticsChanged?([])
            return
        }

        let items = [
            StatisticItem(value: bestPeriod(in: records), title: L10n.Statistics.bestPeriod),
            StatisticItem(
                value: perfectDaysCount(in: records, trackers: trackers),
                title: L10n.Statistics.perfectDays
            ),
            StatisticItem(value: records.count, title: L10n.Statistics.completedTrackers),
            StatisticItem(value: averagePerDay(in: records), title: L10n.Statistics.average)
        ]

        onPlaceholderVisibilityChanged?(false)
        onStatisticsChanged?(items)
    }

    /// Максимальное количество дней подряд по одному трекеру.
    private func bestPeriod(in records: [TrackerRecord]) -> Int {
        let daysByTracker = Dictionary(grouping: records, by: { $0.trackerId })
            .mapValues { Set($0.map { calendar.startOfDay(for: $0.date) }).sorted() }

        var best = 0

        for days in daysByTracker.values {
            var currentStreak = 0
            var previousDay: Date?

            for day in days {
                if let previousDay, calendar.dateComponents([.day], from: previousDay, to: day).day == 1 {
                    currentStreak += 1
                } else {
                    currentStreak = 1
                }
                previousDay = day
                best = max(best, currentStreak)
            }
        }

        return best
    }

    /// Дни, в которые выполнены все запланированные на этот день трекеры.
    private func perfectDaysCount(in records: [TrackerRecord], trackers: [Tracker]) -> Int {
        let completedByDay = Dictionary(grouping: records, by: { calendar.startOfDay(for: $0.date) })
            .mapValues { Set($0.map { $0.trackerId }) }

        return completedByDay.filter { element in
            let scheduledIds = Set(
                trackers
                    .filter { $0.isScheduled(on: element.key, calendar: calendar) }
                    .map { $0.id }
            )

            guard !scheduledIds.isEmpty else { return false }
            return scheduledIds.isSubset(of: element.value)
        }.count
    }

    /// Среднее количество выполненных трекеров за день, в который была активность.
    private func averagePerDay(in records: [TrackerRecord]) -> Int {
        let days = Set(records.map { calendar.startOfDay(for: $0.date) })
        guard !days.isEmpty else { return 0 }
        return Int((Double(records.count) / Double(days.count)).rounded())
    }
}
