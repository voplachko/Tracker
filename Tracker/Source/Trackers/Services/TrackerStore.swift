//
//  TrackerStore.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 16.06.2026.
//

import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidChange()
}

final class TrackerStore: NSObject {
    weak var delegate: TrackerStoreDelegate?

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.title, ascending: true)]

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
            assertionFailure("Failed to fetch trackers: \(error)")
        }
        return controller
    }()

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }

    // MARK: - Public API (domain types only)

    func trackers() throws -> [Tracker] {
        try (fetchedResultsController.fetchedObjects ?? []).map(tracker(from:))
    }

    func deleteTracker(withId id: UUID) throws {
        guard let object = try fetchTrackerCoreData(withId: id) else { return }
        context.delete(object)
        try context.save()
    }

    // MARK: - Store-layer helpers

    @discardableResult
    func makeTrackerCoreData(from tracker: Tracker) -> TrackerCoreData {
        let coreData = TrackerCoreData(context: context)
        coreData.id = tracker.id
        coreData.title = tracker.title
        coreData.emoji = tracker.emoji
        coreData.colorHex = tracker.color.hexString
        coreData.schedule = WeekDay.encode(tracker.schedule)
        return coreData
    }

    func tracker(from coreData: TrackerCoreData) throws -> Tracker {
        guard
            let id = coreData.id,
            let title = coreData.title,
            let emoji = coreData.emoji,
            let colorHex = coreData.colorHex,
            let color = UIColor(hex: colorHex)
        else {
            throw StoreError.decodingError
        }

        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: WeekDay.decode(coreData.schedule ?? "")
        )
    }

    func fetchTrackerCoreData(withId id: UUID) throws -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        // Строковое имя ключа: #keyPath(TrackerCoreData.id) даёт "Ambiguous reference to member 'id'".
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidChange()
    }
}
