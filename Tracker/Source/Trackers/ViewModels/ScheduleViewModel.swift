//
//  ScheduleViewModel.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 24.06.2026.
//

import Foundation

final class ScheduleViewModel {

    let days = WeekDay.allCases

    private(set) var selectedDays: Set<WeekDay>

    init(selectedDays: Set<WeekDay>) {
        self.selectedDays = selectedDays
    }

    func numberOfDays() -> Int {
        days.count
    }

    func dayTitle(at index: Int) -> String {
        days[index].title
    }

    func isDaySelected(at index: Int) -> Bool {
        selectedDays.contains(days[index])
    }

    func setDay(at index: Int, isSelected: Bool) {
        let day = days[index]
        if isSelected {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
}
