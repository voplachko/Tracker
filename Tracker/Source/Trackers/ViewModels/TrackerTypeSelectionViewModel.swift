//
//  TrackerTypeSelectionViewModel.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 24.06.2026.
//

import Foundation

final class TrackerTypeSelectionViewModel {

    var onTypeSelected: Binding<TrackerKind>?

    let habitTitle = L10n.TrackerType.habit
    let irregularEventTitle = L10n.TrackerType.irregularEvent

    func selectHabit() {
        onTypeSelected?(.habit)
    }

    func selectIrregularEvent() {
        onTypeSelected?(.irregularEvent)
    }
}
