//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var onboardingStorage = OnboardingStorage()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeRootViewController()
        window.makeKeyAndVisible()
        self.window = window
    }

    // MARK: - Root

    private func makeRootViewController() -> UIViewController {
        onboardingStorage.hasShownOnboarding
        ? makeMainViewController()
        : makeOnboardingViewController()
    }

    private func makeOnboardingViewController() -> UIViewController {
        let onboarding = OnboardingViewController()
        onboarding.onFinish = { [weak self] in
            self?.completeOnboarding()
        }
        return onboarding
    }

    private func makeMainViewController() -> UIViewController {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return UIViewController()
        }
        return TabBarController(
            categoryStore: appDelegate.categoryStore,
            recordStore: appDelegate.recordStore
        )
    }

    private func completeOnboarding() {
        onboardingStorage.hasShownOnboarding = true
        switchRoot(to: makeMainViewController())
    }

    private func switchRoot(to viewController: UIViewController) {
        guard let window else { return }
        window.rootViewController = viewController
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
}
