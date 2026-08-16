//
//  InMemoryDataBase.swift
//  TrackerTests
//
//  Created by Vsevolod Oplachko on 05.08.2026.
//

import CoreData
@testable import Tracker

enum InMemoryDataBase {

    static func makeContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: "Tracker", managedObjectModel: model)

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }

        return container.viewContext
    }

    private static let model: NSManagedObjectModel = {
        let bundle = Bundle(for: TrackerStore.self)

        guard
            let url = bundle.url(forResource: "Tracker", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: url)
        else {
            fatalError("Failed to load Core Data model")
        }

        return model
    }()
}
