//
//  TabBarController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore

    init(categoryStore: TrackerCategoryStore, recordStore: TrackerRecordStore) {
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        viewControllers = [
            makeTrackersTab(),
            makeStatsTab()
        ]
    }

    private func makeTrackersTab() -> UIViewController {
        makeTab(
            rootViewController: TrackersViewController(
                categoryStore: categoryStore,
                recordStore: recordStore
            ),
            title: "Трекеры",
            image: UIImage(resource: .icTabBarTrackers)
        )
    }

    private func makeStatsTab() -> UIViewController {
        makeTab(
            rootViewController: StatisticsViewController(),
            title: "Статистика",
            image: UIImage(resource: .icTabBarStats)
        )
    }

    private func makeTab(
        rootViewController: UIViewController,
        title: String,
        image: UIImage
    ) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: rootViewController)

        navigationController.tabBarItem = UITabBarItem(
            title: title,
            image: image,
            selectedImage: nil
        )

        return navigationController
    }
}
