//
//  OnboardingStorage.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 23.06.2026.
//

import Foundation

struct OnboardingStorage {
    private enum Keys {
        static let hasShownOnboarding = "hasShownOnboarding"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasShownOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasShownOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasShownOnboarding) }
    }
}
