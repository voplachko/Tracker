//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore

    private var selectedDate = Date() {
        didSet { updateVisibleTrackers() }
    }

    private var visibleCategories: [TrackerCategory] = []
    private var completedRecords: [TrackerRecord] = []

    init(categoryStore: TrackerCategoryStore, recordStore: TrackerRecordStore) {
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private enum Constants {
        static let defaultCategoryTitle = "По умолчанию"
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
        picker.date = selectedDate
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
        categoryStore.delegate = self
        recordStore.delegate = self
        setupView()
        setupNavigationBar()
        setupCollectionView()
        setupPlaceholder()
        updateVisibleTrackers()
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
            image: UIImage(systemName: "plus"),
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
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Dimen.x2), // 8
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Dimen.x4), // 16
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Dimen.x4), // -16
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupPlaceholder() {
        view.addSubview(placeholderStackView)
        
        NSLayoutConstraint.activate([
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderImageView.widthAnchor.constraint(equalToConstant: Dimen.x20),  // 80
            placeholderImageView.heightAnchor.constraint(equalToConstant: Dimen.x20) // 80
        ])
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
        group.interItemSpacing = .fixed(Dimen.x2) // 8
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Dimen.x4 // 16
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: Dimen.x4, // 16
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

// MARK: - Data

private extension TrackersViewController {
    func updateVisibleTrackers() {
        visibleCategories = filteredCategories(for: selectedDate)
        completedRecords = (try? recordStore.records()) ?? []
        updatePlaceholder()
        collectionView.reloadData()
    }

    func updatePlaceholder() {
        let shouldShowPlaceholder = visibleCategories.isEmpty
        placeholderStackView.isHidden = !shouldShowPlaceholder
        collectionView.isHidden = shouldShowPlaceholder
    }

    func filteredCategories(for date: Date) -> [TrackerCategory] {
        guard let selectedWeekDay = WeekDay(date: date) else { return [] }

        let categories = (try? categoryStore.categories()) ?? []
        return categories.compactMap { category in
            let trackers = category.trackers.filter { $0.schedule.contains(selectedWeekDay) }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
    }

    func totalCompletions(for tracker: Tracker) -> Int {
        completedRecords.filter { $0.trackerId == tracker.id }.count
    }

    func isCompleted(_ tracker: Tracker) -> Bool {
        let day = Calendar.current.startOfDay(for: selectedDate)
        return completedRecords.contains {
            $0.trackerId == tracker.id && Calendar.current.startOfDay(for: $0.date) == day
        }
    }
}

// MARK: - Actions

private extension TrackersViewController {
    @objc func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    @objc func addTrackerButtonTapped() {
        let typeSelectionViewController = TrackerTypeSelectionViewController()
        let navigationController = UINavigationController(rootViewController: typeSelectionViewController)
        navigationController.modalPresentationStyle = .pageSheet

        typeSelectionViewController.onHabitSelected = { [weak self, weak navigationController] in
            self?.showTrackerCreation(kind: .habit, in: navigationController)
        }

        typeSelectionViewController.onIrregularEventSelected = { [weak self, weak navigationController] in
            self?.showTrackerCreation(kind: .irregularEvent, in: navigationController)
        }

        present(navigationController, animated: true)
    }

    func showTrackerCreation(
        kind: TrackerCreationViewController.TrackerKind,
        in navigationController: UINavigationController?
    ) {
        let creationViewController = TrackerCreationViewController(kind: kind)
        creationViewController.onCreate = { [weak self] tracker in
            try? self?.categoryStore.addTracker(tracker, toCategoryWithTitle: Constants.defaultCategoryTitle)
            self?.updateVisibleTrackers()
        }

        navigationController?.pushViewController(creationViewController, animated: true)
    }

    func toggleCompletion(for tracker: Tracker) {
        guard !Calendar.current.isDateInFuture(selectedDate) else { return }

        let day = Calendar.current.startOfDay(for: selectedDate)
        let record = TrackerRecord(trackerId: tracker.id, date: day)

        if isCompleted(tracker) {
            try? recordStore.removeRecord(record)
        } else {
            try? recordStore.addRecord(record)
        }

        updateVisibleTrackers()
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
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
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        cell.configure(
            with: tracker,
            isCompleted: isCompleted(tracker),
            count: totalCompletions(for: tracker),
            date: selectedDate
        )
        cell.onToggle = { [weak self] in
            self?.toggleCompletion(for: tracker)
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
        
        header.titleLabel.text = visibleCategories[indexPath.section].title
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {}

// MARK: - Store updates

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func categoryStoreDidChange() {
        updateVisibleTrackers()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func recordStoreDidChange() {
        updateVisibleTrackers()
    }
}
