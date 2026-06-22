//
//  EmojiPickerView.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 16.06.2026.
//

import UIKit

final class EmojiPickerView: UIView {
    var onSelectionChange: (() -> Void)?

    var selectedEmoji: String? {
        guard let indexPath = selectedIndexPath else { return nil }
        return String.trackerEmojis[indexPath.item]
    }

    private var selectedIndexPath: IndexPath?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = .ypBold19
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Dimen.x7),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Dimen.x6),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 168),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - UICollectionViewDataSource

extension EmojiPickerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        String.trackerEmojis.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiCell.reuseIdentifier,
            for: indexPath
        ) as? EmojiCell else {
            return UICollectionViewCell()
        }

        cell.configure(
            emoji: String.trackerEmojis[indexPath.item],
            isSelected: indexPath == selectedIndexPath
        )
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension EmojiPickerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        collectionView.reloadData()
        onSelectionChange?()
    }
}
