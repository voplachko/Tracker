//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 24.06.2026.
//

import Foundation

final class CategoriesViewModel {

    // MARK: - Bindings

    var onCategoriesChanged: Binding<[CategoryCellViewModel]>?
    var onPlaceholderVisibilityChanged: Binding<Bool>?
    var onCategorySelected: Binding<String>?

    // MARK: - Model layer

    private let categoryStore: TrackerCategoryStore

    private(set) var selectedCategoryTitle: String?

    private var categories: [TrackerCategory] = [] {
        didSet { notify() }
    }

    // MARK: - Init

    init(
        categoryStore: TrackerCategoryStore = TrackerCategoryStore(
            context: DataBaseStore.shared.viewContext
        ),
        selectedCategoryTitle: String?
    ) {
        self.categoryStore = categoryStore
        self.selectedCategoryTitle = selectedCategoryTitle
        self.categoryStore.delegate = self
    }

    func viewDidLoad() {
        loadCategories()
    }

    func numberOfCategories() -> Int {
        categories.count
    }

    func cellViewModel(at index: Int) -> CategoryCellViewModel {
        let category = categories[index]
        return CategoryCellViewModel(
            title: category.title,
            isSelected: category.title == selectedCategoryTitle
        )
    }

    func didSelectCategory(at index: Int) {
        let title = categories[index].title
        selectedCategoryTitle = title
        notify()
        onCategorySelected?(title)
    }

    func categoryTitle(at index: Int) -> String {
        categories[index].title
    }

    func addCategory(title: String) {
        try? categoryStore.addCategory(title: title)
    }

    func renameCategory(from oldTitle: String, to newTitle: String) {
        try? categoryStore.updateCategory(oldTitle: oldTitle, newTitle: newTitle)
        if selectedCategoryTitle == oldTitle {
            selectedCategoryTitle = newTitle
        }
    }

    func deleteCategory(at index: Int) {
        let title = categories[index].title
        try? categoryStore.deleteCategory(title: title)
        if selectedCategoryTitle == title {
            selectedCategoryTitle = nil
        }
    }

    // MARK: - Private

    private func loadCategories() {
        categories = (try? categoryStore.categories()) ?? []
    }

    private func makeCellViewModels() -> [CategoryCellViewModel] {
        categories.map {
            CategoryCellViewModel(
                title: $0.title,
                isSelected: $0.title == selectedCategoryTitle
            )
        }
    }

    private func notify() {
        onCategoriesChanged?(makeCellViewModels())
        onPlaceholderVisibilityChanged?(categories.isEmpty)
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func categoryStoreDidChange() {
        loadCategories()
    }
}
