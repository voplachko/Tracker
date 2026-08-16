//
//  TrackersViewControllerSnapshotTests.swift
//  TrackerTests
//
//  Created by Vsevolod Oplachko on 05.08.2026.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {

    // MARK: - Экран с трекерами

    func testTrackersScreenLight() throws {
        let viewController = try makeTrackersViewController(seeded: true)

        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }

    func testTrackersScreenDark() throws {
        let viewController = try makeTrackersViewController(seeded: true)

        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark))
        )
    }

    // MARK: - Пустое состояние

    func testTrackersPlaceholderLight() throws {
        let viewController = try makeTrackersViewController(seeded: false)

        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }

    func testTrackersPlaceholderDark() throws {
        let viewController = try makeTrackersViewController(seeded: false)

        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark))
        )
    }

    // MARK: - Helpers

    /// Экран собирается на in-memory Core Data стеке с фиксированной датой,
    /// чтобы снапшот не зависел ни от данных на устройстве, ни от текущего дня.
    private func makeTrackersViewController(seeded: Bool) throws -> UIViewController {
        let context = InMemoryDataBase.makeContext()
        let trackerStore = TrackerStore(context: context)
        let categoryStore = TrackerCategoryStore(context: context, trackerStore: trackerStore)
        let recordStore = TrackerRecordStore(context: context, trackerStore: trackerStore)

        if seeded {
            try TrackerFixtures.seed(categoryStore: categoryStore, recordStore: recordStore)
        }

        let viewController = TrackersViewController(
            categoryStore: categoryStore,
            recordStore: recordStore,
            filterStorage: TrackerFilterStorage(userDefaults: makeCleanUserDefaults()),
            selectedDate: TrackerFixtures.date
        )

        return UINavigationController(rootViewController: viewController)
    }

    /// Фильтр хранится в UserDefaults, поэтому тест использует отдельный чистый
    /// суит: иначе состояние симулятора попадало бы в снапшоты.
    private func makeCleanUserDefaults() -> UserDefaults {
        let suiteName = "TrackerTests.\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else { return .standard }

        addTeardownBlock {
            userDefaults.removePersistentDomain(forName: suiteName)
        }
        return userDefaults
    }
}
