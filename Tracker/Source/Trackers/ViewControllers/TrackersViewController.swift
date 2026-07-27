//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit

final class TrackersViewController: UIViewController {

    private let viewModel: TrackersViewModel

    init(categoryStore: TrackerCategoryStore, recordStore: TrackerRecordStore) {
        self.viewModel = TrackersViewModel(categoryStore: categoryStore, recordStore: recordStore)
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
        label.text = "Что будем отслеживать?"
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

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.date = viewModel.selectedDate
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        NSLayoutConstraint.activate([
            picker.widthAnchor.constraint(equalToConstant: 110)
        ])
        return picker
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

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
        setupCollectionView()
        setupPlaceholder()
        bindViewModel()
        viewModel.viewDidLoad()
    }
}

// MARK: - Setup

private extension TrackersViewController {
    func setupView() {
        view.backgroundColor = .systemBackground
    }

    func setupNavigationBar() {
        title = "Трекеры"
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

    func setupCollectionView() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Dimen.x2),
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

        viewModel.onPlaceholderVisibilityChanged = { [weak self] shouldShowPlaceholder in
            self?.placeholderStackView.isHidden = !shouldShowPlaceholder
            self?.collectionView.isHidden = shouldShowPlaceholder
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

    @objc func addTrackerButtonTapped() {
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
        let creationViewController = TrackerCreationViewController(kind: kind)
        creationViewController.onCreate = { [weak self] tracker, categoryTitle in
            self?.viewModel.addTracker(tracker, categoryTitle: categoryTitle)
        }

        navigationController?.pushViewController(creationViewController, animated: true)
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

            let pinTitle = self.viewModel.isPinned(at: indexPath) ? "Открепить" : "Закрепить"
            let pinAction = UIAction(title: pinTitle) { [weak self] _ in
                self?.viewModel.togglePin(at: indexPath)
            }
            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                self?.editTracker(at: indexPath)
            }
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
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
            message: "Уверены, что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteTracker(at: indexPath)
        })
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))

        if let popover = alert.popoverPresentationController,
           let cell = collectionView.cellForItem(at: indexPath) {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }

        present(alert, animated: true)
    }
}
