//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit

final class TrackersViewController: UIViewController {

    private enum Constants {
        static let filtersButtonWidth: CGFloat = 114
        static let filtersButtonHeight: CGFloat = 50
        static let searchFieldHeight: CGFloat = 36
        static let datePickerWidth: CGFloat = 110
        /// Отступ снизу, чтобы кнопка «Фильтры» не перекрывала последние ячейки
        static let collectionBottomInset: CGFloat = 82
    }

    private let viewModel: TrackersViewModel
    private let analyticsService: AnalyticsService

    init(
        categoryStore: TrackerCategoryStore,
        recordStore: TrackerRecordStore,
        filterStorage: TrackerFilterStorage = TrackerFilterStorage(),
        selectedDate: Date = Date(),
        analyticsService: AnalyticsService = .shared
    ) {
        self.viewModel = TrackersViewModel(
            categoryStore: categoryStore,
            recordStore: recordStore,
            filterStorage: filterStorage,
            selectedDate: selectedDate
        )
        self.analyticsService = analyticsService
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - UI

    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .emptyTrackers)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Trackers.placeholder
        label.font = .ypRegular12
        label.textColor = .label
        label.textAlignment = .center
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

    private lazy var searchTextField: UISearchTextField = {
        let searchTextField = UISearchTextField()
        searchTextField.placeholder = L10n.Trackers.searchPlaceholder
        searchTextField.font = .ypRegular17
        searchTextField.returnKeyType = .search
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(searchTextDidChange), for: .editingChanged)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        return searchTextField
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.date = viewModel.selectedDate
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        NSLayoutConstraint.activate([
            picker.widthAnchor.constraint(equalToConstant: Constants.datePickerWidth)
        ])
        return picker
    }()

    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.Filters.title, for: .normal)
        button.setTitleColor(.ypWhiteDay, for: .normal)
        button.titleLabel?.font = .ypRegular17
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = Dimen.x4
        button.isHidden = true
        button.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.keyboardDismissMode = .onDrag

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseId)
        collectionView.register(
            TrackerHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeaderView.reuseId
        )
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupSearchTextField()
        setupCollectionView()
        setupPlaceholder()
        setupFiltersButton()
        setupKeyboardDismiss()
        bindViewModel()
        viewModel.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: .open, screen: .main)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: .close, screen: .main)
    }
}

// MARK: - Setup

private extension TrackersViewController {
    func setupView() {
        view.backgroundColor = .systemBackground
    }

    func setupNavigationBar() {
        title = L10n.Trackers.title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let addButton = UIBarButtonItem(
            image: UIImage(sfSymbol: .plus),
            style: .plain,
            target: self,
            action: #selector(addTrackerButtonTapped)
        )
        addButton.tintColor = .label

        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    func setupSearchTextField() {
        view.addSubview(searchTextField)

        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Dimen.x2),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Dimen.x4),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Dimen.x4),
            searchTextField.heightAnchor.constraint(equalToConstant: Constants.searchFieldHeight)
        ])
    }

    /// Тап по свободной области экрана снимает фокус с поисковой строки.
    /// `cancelsTouchesInView` выключен, чтобы нажатия доходили до ячеек и кнопок.
    func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    func setupFiltersButton() {
        view.addSubview(filtersButton)

        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Dimen.x4
            ),
            filtersButton.widthAnchor.constraint(equalToConstant: Constants.filtersButtonWidth),
            filtersButton.heightAnchor.constraint(equalToConstant: Constants.filtersButtonHeight)
        ])
    }

    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.contentInset.bottom = Constants.collectionBottomInset

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: Dimen.x2),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Dimen.x4),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Dimen.x4),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupPlaceholder() {
        view.addSubview(placeholderStackView)

        NSLayoutConstraint.activate([
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            placeholderImageView.widthAnchor.constraint(equalToConstant: Dimen.x20),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Dimen.x20)
        ])
    }

    func bindViewModel() {
        viewModel.onDataChanged = { [weak self] in
            self?.collectionView.reloadData()
        }

        viewModel.onPlaceholderStateChanged = { [weak self] state in
            self?.showPlaceholder(state)
        }

        viewModel.onFiltersButtonVisibilityChanged = { [weak self] isVisible in
            self?.filtersButton.isHidden = !isVisible
        }

        viewModel.onDateChanged = { [weak self] date in
            self?.datePicker.date = date
        }
    }

    func showPlaceholder(_ state: TrackersViewModel.PlaceholderState) {
        switch state {
        case .hidden:
            placeholderStackView.isHidden = true
            collectionView.isHidden = false
        case .noTrackers:
            placeholderImageView.image = UIImage(resource: .emptyTrackers)
            placeholderLabel.text = L10n.Trackers.placeholder
            placeholderStackView.isHidden = false
            collectionView.isHidden = true
        case .nothingFound:
            placeholderImageView.image = UIImage(resource: .notFoundTrackers)
            placeholderLabel.text = L10n.Trackers.nothingFound
            placeholderStackView.isHidden = false
            collectionView.isHidden = true
        }
    }

    func makeLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(132)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(132)
            ),
            subitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(Dimen.x2)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Dimen.x4
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: Dimen.x4,
            trailing: 0
        )
        section.boundarySupplementaryItems = [makeHeader()]

        return UICollectionViewCompositionalLayout(section: section)
    }

    func makeHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(35)
        )

        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}

// MARK: - Actions

private extension TrackersViewController {
    @objc func dateChanged(_ sender: UIDatePicker) {
        viewModel.setDate(sender.date)
    }

    @objc func searchTextDidChange(_ sender: UISearchTextField) {
        viewModel.setSearchQuery(sender.text)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    @objc func filtersButtonTapped() {
        analyticsService.report(event: .click, screen: .main, item: .filter)

        let filtersViewModel = FiltersViewModel(selectedFilter: viewModel.currentFilter)
        let filtersViewController = FiltersViewController(viewModel: filtersViewModel)
        filtersViewController.onFilterSelect = { [weak self] filter in
            self?.viewModel.setFilter(filter)
        }

        let navigationController = UINavigationController(rootViewController: filtersViewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }

    @objc func addTrackerButtonTapped() {
        analyticsService.report(event: .click, screen: .main, item: .addTrack)

        let typeSelectionViewController = TrackerTypeSelectionViewController()
        let navigationController = UINavigationController(rootViewController: typeSelectionViewController)
        navigationController.modalPresentationStyle = .pageSheet

        typeSelectionViewController.onTypeSelected = { [weak self, weak navigationController] kind in
            self?.showTrackerCreation(kind: kind, in: navigationController)
        }

        present(navigationController, animated: true)
    }

    func showTrackerCreation(
        kind: TrackerKind,
        in navigationController: UINavigationController?
    ) {
        let creationViewController = TrackerCreationViewController(
            kind: kind,
            selectedDate: viewModel.selectedDate
        )
        creationViewController.onCreate = { [weak self] tracker, categoryTitle in
            self?.viewModel.addTracker(tracker, categoryTitle: categoryTitle)
        }

        navigationController?.pushViewController(creationViewController, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.setSearchQuery(nil)
        return true
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems(in: section)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseId,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let model = viewModel.cellModel(at: indexPath)
        cell.configure(
            with: model.tracker,
            isCompleted: model.isCompleted,
            count: model.completionCount,
            date: model.date
        )
        cell.onToggle = { [weak self] in
            self?.analyticsService.report(event: .click, screen: .main, item: .track)
            self?.viewModel.toggleCompletion(for: model.tracker)
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerHeaderView.reuseId,
                for: indexPath
            ) as? TrackerHeaderView
        else {
            return UICollectionReusableView()
        }

        header.titleLabel.text = viewModel.categoryTitle(in: indexPath.section)
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let identifier = NSIndexPath(item: indexPath.item, section: indexPath.section)
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { [weak self] _ in
            guard let self else { return nil }

            let pinTitle = self.viewModel.isPinned(at: indexPath)
            ? L10n.Trackers.unpin
            : L10n.Trackers.pin
            let pinAction = UIAction(title: pinTitle) { [weak self] _ in
                self?.viewModel.togglePin(at: indexPath)
            }
            let editAction = UIAction(title: L10n.Common.edit) { [weak self] _ in
                self?.analyticsService.report(event: .click, screen: .main, item: .edit)
                self?.editTracker(at: indexPath)
            }
            let deleteAction = UIAction(title: L10n.Common.delete, attributes: .destructive) { [weak self] _ in
                self?.analyticsService.report(event: .click, screen: .main, item: .delete)
                self?.confirmDeleteTracker(at: indexPath)
            }
            return UIMenu(children: [pinAction, editAction, deleteAction])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        targetedPreview(for: configuration)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        targetedPreview(for: configuration)
    }
}

// MARK: - Context menu helpers

private extension TrackersViewController {
    func targetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let identifier = configuration.identifier as? NSIndexPath else { return nil }
        let indexPath = IndexPath(item: identifier.item, section: identifier.section)
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else { return nil }

        let cardView = cell.previewTargetView

        let renderer = UIGraphicsImageRenderer(bounds: cardView.bounds)
        let image = renderer.image { _ in
            cardView.drawHierarchy(in: cardView.bounds, afterScreenUpdates: false)
        }

        let snapshotView = UIImageView(image: image)
        snapshotView.bounds = cardView.bounds
        snapshotView.layer.cornerRadius = Dimen.x4
        snapshotView.layer.masksToBounds = true

        let center = cardView.convert(
            CGPoint(x: cardView.bounds.midX, y: cardView.bounds.midY),
            to: collectionView
        )
        let previewTarget = UIPreviewTarget(container: collectionView, center: center)

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        return UITargetedPreview(view: snapshotView, parameters: parameters, target: previewTarget)
    }

    func editTracker(at indexPath: IndexPath) {
        let context = viewModel.editingContext(at: indexPath)
        let creationViewController = TrackerCreationViewController(
            editing: context.tracker,
            categoryTitle: context.categoryTitle,
            daysCount: context.daysCount
        )
        creationViewController.onSave = { [weak self] tracker, categoryTitle in
            self?.viewModel.updateTracker(tracker, categoryTitle: categoryTitle)
        }

        let navigationController = UINavigationController(rootViewController: creationViewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }

    func confirmDeleteTracker(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: nil,
            message: L10n.Trackers.deleteConfirmation,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: L10n.Common.delete, style: .destructive) { [weak self] _ in
            self?.viewModel.deleteTracker(at: indexPath)
        })
        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))

        if let popover = alert.popoverPresentationController,
           let cell = collectionView.cellForItem(at: indexPath) {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }

        present(alert, animated: true)
    }
}
