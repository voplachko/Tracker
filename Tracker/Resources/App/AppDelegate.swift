//
//  AppDelegate.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Data layer (composition root)

    private(set) lazy var trackerStore = TrackerStore(
        context: DataBaseStore.shared.viewContext
    )

    private(set) lazy var categoryStore = TrackerCategoryStore(
        context: DataBaseStore.shared.viewContext,
        trackerStore: trackerStore
    )

    private(set) lazy var recordStore = TrackerRecordStore(
        context: DataBaseStore.shared.viewContext,
        trackerStore: trackerStore
    )

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        true
    }

    // MARK: - UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
