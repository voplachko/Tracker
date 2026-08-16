//
//  TrackerFixtures.swift
//  TrackerTests
//
//  Created by Vsevolod Oplachko on 16.08.2026.
//

import CoreData
import UIKit
@testable import Tracker

/// Детерминированные данные для снапшотов: фиксированная дата и заранее
/// заданный набор трекеров. Дата зафиксирована потому, что на главном экране
/// виден `UIDatePicker`, и эталон, снятый с текущим днём, устареет назавтра.
enum TrackerFixtures {

    /// Понедельник, 5 января 2026 года.
    static let date: Date = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        let components = DateComponents(year: 2026, month: 1, day: 5, hour: 12)
        guard let date = calendar.date(from: components) else {
            fatalError("Failed to build fixture date")
        }
        return date
    }()

    static let categoryTitle = "Домашний уют"

    /// Привычка по понедельникам и средам, отмеченная выполненной на зафиксированную дату.
    static let habit = Tracker(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
        title: "Поливать растения",
        color: UIColor.trackerColors[4],
        emoji: "❤️",
        schedule: [.monday, .wednesday],
        eventDate: nil,
        isPinned: false
    )

    /// Нерегулярное событие, назначенное на зафиксированную дату.
    static let irregularEvent = Tracker(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID(),
        title: "Сходить к врачу",
        color: UIColor.trackerColors[1],
        emoji: "🌺",
        schedule: [],
        eventDate: date,
        isPinned: true
    )

    /// Заполняет стор так, чтобы на экране были и закреплённая секция,
    /// и обычная категория, и выполненный, и невыполненный трекер.
    static func seed(
        categoryStore: TrackerCategoryStore,
        recordStore: TrackerRecordStore
    ) throws {
        try categoryStore.addTracker(habit, toCategoryWithTitle: categoryTitle)
        try categoryStore.addTracker(irregularEvent, toCategoryWithTitle: categoryTitle)
        try recordStore.addRecord(TrackerRecord(trackerId: habit.id, date: startOfDay))
    }

    private static var startOfDay: Date {
        Calendar.current.startOfDay(for: date)
    }
}
