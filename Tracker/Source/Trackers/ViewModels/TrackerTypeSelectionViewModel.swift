//
//  TrackerTypeSelectionViewModel.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 24.06.2026.
//

import Foundation

final class TrackerTypeSelectionViewModel {

    var onTypeSelected: Binding<TrackerKind>?

    let habitTitle = "Привычка"
    let irregularEventTitle = "Нерегулярное событие"

    func selectHabit() {
        onTypeSelected?(.habit)
    }

    func selectIrregularEvent() {
        onTypeSelected?(.irregularEvent)
    }
}
