//
//  Colors+Ext.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit

extension UIColor {

    // universal colors
    static let ypRed = UIColor(red: 245 / 255, green: 107 / 255, blue: 108 / 255, alpha: 1)
    static let ypGray = UIColor(red: 174 / 255, green: 175 / 255, blue: 180 / 255, alpha: 1)
    static let ypBlue = UIColor(red: 55 / 255, green: 114 / 255, blue: 231 / 255, alpha: 1)

    // fixed colors: used where the palette does not depend on the interface style
    // (onboarding shows dark text over a light illustration)
    static let ypBlackDay = UIColor(red: 26 / 255, green: 27 / 255, blue: 34 / 255, alpha: 1)
    static let ypWhiteDay = UIColor.white
    static let ypBackgroundDay = UIColor(red: 230 / 255, green: 232 / 255, blue: 235 / 255, alpha: 0.3)
    static let ypBackgroundNight = UIColor(red: 65 / 255, green: 65 / 255, blue: 65 / 255, alpha: 0.85)

    // adaptive colors: resolved for light and dark interface styles
    static let ypBlack = UIColor { traits in
        traits.userInterfaceStyle == .dark ? .ypWhiteDay : .ypBlackDay
    }

    static let ypWhite = UIColor { traits in
        traits.userInterfaceStyle == .dark ? .ypBlackDay : .ypWhiteDay
    }

    static let ypBackground = UIColor { traits in
        traits.userInterfaceStyle == .dark ? .ypBackgroundNight : .ypBackgroundDay
    }

    // gradient for statistics cards
    static let ypGradient: [UIColor] = [
        UIColor(red: 253 / 255, green: 76 / 255, blue: 73 / 255, alpha: 1),
        UIColor(red: 70 / 255, green: 230 / 255, blue: 157 / 255, alpha: 1),
        UIColor(red: 0 / 255, green: 123 / 255, blue: 250 / 255, alpha: 1)
    ]

    // colors for trackers
    static let trackerColors: [UIColor] = [
        UIColor(red: 253 / 255, green: 76 / 255, blue: 73 / 255, alpha: 1),
        UIColor(red: 255 / 255, green: 136 / 255, blue: 30 / 255, alpha: 1),
        UIColor(red: 0 / 255, green: 123 / 255, blue: 250 / 255, alpha: 1),
        UIColor(red: 110 / 255, green: 68 / 255, blue: 254 / 255, alpha: 1),
        UIColor(red: 51 / 255, green: 207 / 255, blue: 105 / 255, alpha: 1),
        UIColor(red: 230 / 255, green: 109 / 255, blue: 212 / 255, alpha: 1),
        UIColor(red: 249 / 255, green: 212 / 255, blue: 212 / 255, alpha: 1),
        UIColor(red: 52 / 255, green: 167 / 255, blue: 254 / 255, alpha: 1),
        UIColor(red: 70 / 255, green: 230 / 255, blue: 157 / 255, alpha: 1),
        UIColor(red: 53 / 255, green: 52 / 255, blue: 124 / 255, alpha: 1),
        UIColor(red: 255 / 255, green: 103 / 255, blue: 77 / 255, alpha: 1),
        UIColor(red: 255 / 255, green: 153 / 255, blue: 204 / 255, alpha: 1),
        UIColor(red: 246 / 255, green: 196 / 255, blue: 139 / 255, alpha: 1),
        UIColor(red: 121 / 255, green: 148 / 255, blue: 245 / 255, alpha: 1),
        UIColor(red: 131 / 255, green: 44 / 255, blue: 241 / 255, alpha: 1),
        UIColor(red: 173 / 255, green: 86 / 255, blue: 218 / 255, alpha: 1),
        UIColor(red: 141 / 255, green: 114 / 255, blue: 230 / 255, alpha: 1),
        UIColor(red: 47 / 255, green: 208 / 255, blue: 88 / 255, alpha: 1)
    ]
}
