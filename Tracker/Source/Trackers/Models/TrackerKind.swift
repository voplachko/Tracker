//
//  TrackerKind.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 16.08.2026.
//

import Foundation

enum TrackerKind {
    /// Привычка: повторяется по выбранным дням недели.
    case habit
    /// Нерегулярное событие: показывается только в тот день, на который создано.
    case irregularEvent
}
