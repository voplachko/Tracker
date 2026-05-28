//
//  TabBarController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerVC = TrackersViewController()
        let statsVC = StatisticsViewController()
        
        let trackersNav = UINavigationController(rootViewController: trackerVC)
        let statsNav = UINavigationController(rootViewController: statsVC)
        
        trackersNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .icTabBarTrackers),
            selectedImage: nil
        )
        
        statsNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .icTabBarStats),
            selectedImage: nil
        )
        
        viewControllers = [trackersNav, statsNav]
    }
}
