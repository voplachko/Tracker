//
//  DataBaseStore.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 22.06.2026.
//

import CoreData

/// Owns the Core Data stack. Working with persistence is not the
/// AppDelegate's responsibility, so the stack lives here as a single
/// shared entry point: `DataBaseStore.shared`.
final class DataBaseStore {
    static let shared = DataBaseStore()

    private let modelName = "Tracker"

    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private init() {}

    func saveContext() {
        let context = viewContext
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            assertionFailure("Unresolved Core Data error \(nsError), \(nsError.userInfo)")
        }
    }
}
