//
//  FiltersViewModel.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 05.08.2026.
//

import Foundation

final class FiltersViewModel {

    var onFiltersChanged: Binding<[SelectableCellViewModel]>?
    var onFilterSelected: Binding<TrackerFilter>?

    private let filters = TrackerFilter.allCases
    private var selectedFilter: TrackerFilter

    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
    }

    func viewDidLoad() {
        onFiltersChanged?(makeCellViewModels())
    }

    func didSelectFilter(at index: Int) {
        guard filters.indices.contains(index) else { return }

        let filter = filters[index]
        selectedFilter = filter
        onFiltersChanged?(makeCellViewModels())
        onFilterSelected?(filter)
    }

    private func makeCellViewModels() -> [SelectableCellViewModel] {
        filters.map {
            SelectableCellViewModel(
                title: $0.title,
                // «Все трекеры» и «Трекеры на сегодня» галочкой не отмечаются
                isSelected: $0.isActive && $0 == selectedFilter
            )
        }
    }
}
