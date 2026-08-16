//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 05.08.2026.
//

import Foundation
import AppMetricaCore

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

enum AnalyticsScreen: String {
    case main = "Main"
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track
    case filter
    case edit
    case delete
}

/// Тонкая обёртка над AppMetrica: событие всегда состоит из
/// `event`, `screen` и (для кликов) `item`.
final class AnalyticsService {

    static let shared = AnalyticsService()

    private enum Constants {
        /// API key приложения из интерфейса AppMetrica.
        /// Ключ приватный и в репозиторий не коммитится. Без него SDK не активируется,
        /// приложение работает штатно, а отправляемые события видны
        /// в консоли DEBUG-сборки (см. `report(event:screen:item:)`).
        static let apiKey = "APPMETRICA_API_KEY"
    }

    private init() {}

    func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: Constants.apiKey) else {
            print("AppMetrica: API key не задан, SDK не активирован")
            return
        }
        AppMetrica.activate(with: configuration)
    }

    func report(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem? = nil) {
        var parameters: [AnyHashable: Any] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]

        if let item {
            parameters["item"] = item.rawValue
        }

        AppMetrica.reportEvent(name: event.rawValue, parameters: parameters) { error in
            print("AppMetrica report error: \(error.localizedDescription)")
        }

        #if DEBUG
        print("Analytics: \(parameters)")
        #endif
    }
}
