//
//  SelectableCellViewModel.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 05.08.2026.
//

import Foundation

/// Модель строки списка с выбором: используется и для категорий, и для фильтров.
struct SelectableCellViewModel: Equatable {
    let title: String
    let isSelected: Bool
}
