//
//  Tracker.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 29.05.2026.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: Set<WeekDay>
}

enum WeekDay: Int, CaseIterable {
    case monday = 1
    case tuesday, wednesday,
         thursday, friday,
         saturday, sunday
}
