//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 05.08.2026.
//

import UIKit

final class FiltersViewController: UIViewController {

    private enum Constants {
        static let rowHeight: CGFloat = 75
    }

    var onFilterSelect: Binding<TrackerFilter>?

    private let viewModel: FiltersViewModel
    private var cellViewModels: [SelectableCellViewModel] = []

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    init(viewModel: FiltersViewModel) {
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

private extension FiltersViewController {
    func setupView() {
        title = L10n.Filters.title
        view.backgroundColor = .systemBackground
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SelectableCell.self, forCellReuseIdentifier: SelectableCell.reuseIdentifier)
    }

    func setupConstraints() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Dimen.x6),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Dimen.x4),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Dimen.x4),
            tableView.heightAnchor.constraint(
                equalToConstant: Constants.rowHeight * CGFloat(TrackerFilter.allCases.count)
            )
        ])
    }

    func bindViewModel() {
        viewModel.onFiltersChanged = { [weak self] cellViewModels in
            self?.cellViewModels = cellViewModels
            self?.tableView.reloadData()
        }

        viewModel.onFilterSelected = { [weak self] filter in
            self?.onFilterSelect?(filter)
            self?.dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SelectableCell.reuseIdentifier,
            for: indexPath
        ) as? SelectableCell else {
            return UITableViewCell()
        }

        cell.configure(
            with: cellViewModels[indexPath.row],
            position: SelectableCell.Position(row: indexPath.row, totalRows: cellViewModels.count)
        )
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectFilter(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.rowHeight
    }
}
