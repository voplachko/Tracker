//
//  AppDelegate.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit
import CoreData

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    // MARK: - Data layer (composition root)

    private(set) lazy var trackerStore = TrackerStore(
        context: persistentContainer.viewContext
    )

    private(set) lazy var categoryStore = TrackerCategoryStore(
        context: persistentContainer.viewContext,
        trackerStore: trackerStore
    )

    private(set) lazy var recordStore = TrackerRecordStore(
        context: persistentContainer.viewContext,
        trackerStore: trackerStore
    )

    func saveContext() {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            assertionFailure("Unresolved Core Data error \(nsError), \(nsError.userInfo)")
        }
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}


}

