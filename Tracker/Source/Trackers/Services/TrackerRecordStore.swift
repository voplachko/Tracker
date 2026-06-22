//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 16.06.2026.
//

import Foundation
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func recordStoreDidChange()
}

final class TrackerRecordStore: NSObject {
    weak var delegate: TrackerRecordStoreDelegate?

    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)]

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
            assertionFailure("Failed to fetch records: \(error)")
        }
        return controller
    }()

    init(context: NSManagedObjectContext, trackerStore: TrackerStore? = nil) {
        self.context = context
        self.trackerStore = trackerStore ?? TrackerStore(context: context)
        super.init()
    }

    // MARK: - Public API (domain types only)

    func records() throws -> [TrackerRecord] {
        try (fetchedResultsController.fetchedObjects ?? []).map(record(from:))
    }

    func addRecord(_ record: TrackerRecord) throws {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.id = UUID()
        recordCoreData.date = record.date
        recordCoreData.tracker = try trackerStore.fetchTrackerCoreData(withId: record.trackerId)
        try context.save()
    }

    func removeRecord(_ record: TrackerRecord) throws {
        guard let object = try fetchRecordCoreData(trackerId: record.trackerId, date: record.date) else { return }
        context.delete(object)
        try context.save()
    }

    // MARK: - Mapping / helpers

    private func record(from coreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard
            let date = coreData.date,
            let trackerId = coreData.tracker?.id
        else {
            throw StoreError.decodingError
        }

        return TrackerRecord(trackerId: trackerId, date: date)
    }

    private func fetchRecordCoreData(trackerId: UUID, date: Date) throws -> TrackerRecordCoreData? {
        guard let trackerCoreData = try trackerStore.fetchTrackerCoreData(withId: trackerId) else { return nil }

        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.tracker), trackerCoreData,
            #keyPath(TrackerRecordCoreData.date), date as NSDate
        )
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.recordStoreDidChange()
    }
}
