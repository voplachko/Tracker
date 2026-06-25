//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 24.06.2026.
//

import UIKit

final class CategoriesViewController: UIViewController {

    private enum Constants {
        static let rowHeight: CGFloat = 75
        static let buttonHeight: CGFloat = 60
    }

    var onCategorySelect: ((String) -> Void)?

    private let viewModel: CategoriesViewModel
    private var cellViewModels: [CategoryCellViewModel] = []

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = Dimen.x4
        tableView.layer.masksToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .emptyTrackers))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = .ypMedium12
        label.textColor = .ypBlackDay
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var placeholderStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [placeholderImageView, placeholderLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Dimen.x2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var addButton: PrimaryButton = {
        let button = PrimaryButton(title: "Добавить категорию")
        button.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        return button
    }()

    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupConstraints()
        bindViewModel()
        viewModel.viewDidLoad()
    }
}

// MARK: - Setup

private extension CategoriesViewController {
    func setupView() {
        title = "Категория"
        view.backgroundColor = .systemBackground
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
    }

    func setupConstraints() {
        view.addSubview(tableView)
        view.addSubview(placeholderStackView)
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Dimen.x6),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Dimen.x4),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Dimen.x4),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -Dimen.x4),

            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: Dimen.x20),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Dimen.x20),

            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Dimen.x5),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Dimen.x5),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Dimen.x4),
            addButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] cellViewModels in
            self?.cellViewModels = cellViewModels
            self?.tableView.reloadData()
        }

        viewModel.onPlaceholderVisibilityChanged = { [weak self] isEmpty in
            self?.placeholderStackView.isHidden = !isEmpty
            self?.tableView.isHidden = isEmpty
        }

        viewModel.onCategorySelected = { [weak self] title in
            self?.onCategorySelect?(title)
            self?.navigationController?.popViewController(animated: true)
        }
    }

    @objc func addCategoryTapped() {
        let newCategoryViewModel = NewCategoryViewModel()
        newCategoryViewModel.onCategoryReady = { [weak self] title in
            self?.viewModel.addCategory(title: title)
            self?.navigationController?.popViewController(animated: true)
        }
        let newCategoryViewController = NewCategoryViewController(viewModel: newCategoryViewModel)
        navigationController?.pushViewController(newCategoryViewController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }

        cell.configure(with: cellViewModels[indexPath.row])
        let isLastCell = indexPath.row == cellViewModels.count - 1
        cell.setSeparatorHidden(isLastCell)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectCategory(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.rowHeight
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                self?.editCategory(at: indexPath)
            }
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                self?.confirmDeleteCategory(at: indexPath)
            }
            return UIMenu(children: [editAction, deleteAction])
        }
    }
}

// MARK: - Context menu helpers

private extension CategoriesViewController {
    func editCategory(at indexPath: IndexPath) {
        let currentTitle = viewModel.categoryTitle(at: indexPath.row)
        let editViewModel = NewCategoryViewModel(mode: .edit(currentTitle: currentTitle))
        editViewModel.onCategoryReady = { [weak self] newTitle in
            self?.viewModel.renameCategory(from: currentTitle, to: newTitle)
            self?.navigationController?.popViewController(animated: true)
        }
        let editViewController = NewCategoryViewController(viewModel: editViewModel)
        navigationController?.pushViewController(editViewController, animated: true)
    }

    func confirmDeleteCategory(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: nil,
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: indexPath.row)
        })
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))

        if let popover = alert.popoverPresentationController,
           let cell = tableView.cellForRow(at: indexPath) {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }

        present(alert, animated: true)
    }
}
