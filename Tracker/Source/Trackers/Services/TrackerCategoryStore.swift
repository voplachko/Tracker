//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 16.06.2026.
//

import Foundation
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func categoryStoreDidChange()
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?

    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            assertionFailure("Failed to fetch categories: \(error)")
        }
        return controller
    }()

    init(context: NSManagedObjectContext, trackerStore: TrackerStore? = nil) {
        self.context = context
        self.trackerStore = trackerStore ?? TrackerStore(context: context)
        super.init()
    }

    // MARK: - Public API (domain types only)

    func categories() throws -> [TrackerCategory] {
        try (fetchedResultsController.fetchedObjects ?? []).map(category(from:))
    }

    func addCategory(title: String) throws {
        guard try fetchCategoryCoreData(withTitle: title) == nil else { return }
        _ = makeCategoryCoreData(title: title)
        try context.save()
    }

    func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) throws {
        let categoryCoreData = try fetchCategoryCoreData(withTitle: title) ?? makeCategoryCoreData(title: title)
        let trackerCoreData = trackerStore.makeTrackerCoreData(from: tracker)
        trackerCoreData.category = categoryCoreData
        try context.save()
    }

    func updateTracker(_ tracker: Tracker, toCategoryWithTitle title: String) throws {
        guard let trackerCoreData = try trackerStore.fetchTrackerCoreData(withId: tracker.id) else { return }
        trackerStore.apply(tracker, to: trackerCoreData)
        let categoryCoreData = try fetchCategoryCoreData(withTitle: title) ?? makeCategoryCoreData(title: title)
        trackerCoreData.category = categoryCoreData
        try context.save()
    }

    func deleteTracker(withId id: UUID) throws {
        try trackerStore.deleteTracker(withId: id)
    }

    func setPinned(_ isPinned: Bool, forTrackerWithId id: UUID) throws {
        try trackerStore.setPinned(isPinned, forTrackerWithId: id)
    }

    func deleteCategory(title: String) throws {
        guard let coreData = try fetchCategoryCoreData(withTitle: title) else { return }
        context.delete(coreData)
        try context.save()
    }

    func updateCategory(oldTitle: String, newTitle: String) throws {
        guard let coreData = try fetchCategoryCoreData(withTitle: oldTitle) else { return }
        coreData.title = newTitle
        try context.save()
    }

    // MARK: - Mapping / helpers

    private func category(from coreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = coreData.title else { throw StoreError.decodingError }

        let trackerObjects = (coreData.trackers as? Set<TrackerCoreData>) ?? []
        let trackers = try trackerObjects.map(trackerStore.tracker(from:))

        return TrackerCategory(title: title, trackers: trackers)
    }

    @discardableResult
    private func makeCategoryCoreData(title: String) -> TrackerCategoryCoreData {
        let coreData = TrackerCategoryCoreData(context: context)
        coreData.title = title
        return coreData
    }

    private func fetchCategoryCoreData(withTitle title: String) throws -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.title), title
        )
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.categoryStoreDidChange()
    }
}
