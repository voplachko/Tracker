//
//  TrackerCell.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 01.06.2026.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    static let reuseId = "TrackerCell"

    var onToggle: (() -> Void)?

    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Dimen.x4
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = Dimen.x3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .ypRegular14
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .ypMedium12
        label.numberOfLines = 2
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let counterLabel: UILabel = {
        let label = UILabel()
        label.font = .ypMedium12
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = Dimen.x9 / 2
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
        setupActions()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onToggle = nil
        toggleButton.alpha = 1
        toggleButton.isEnabled = true
    }

    func configure(with tracker: Tracker, isCompleted: Bool, count: Int, date: Date) {
        let isFutureDate = Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())

        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        counterLabel.text = "\(count) \(Self.daysString(for: count))"

        toggleButton.backgroundColor = tracker.color
        toggleButton.tintColor = .white

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: Dimen.x3, weight: .regular)
        let symbolName = isCompleted ? "checkmark" : "plus"
        let symbolImage = UIImage(systemName: symbolName, withConfiguration: symbolConfig)
        toggleButton.setImage(symbolImage, for: .normal)

        toggleButton.isEnabled = !isFutureDate

        if isFutureDate {
            toggleButton.alpha = 0.5
        } else {
            toggleButton.alpha = isCompleted ? 0.3 : 1
        }
    }
}

private extension TrackerCell {
    func setupView() {
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        contentView.addSubview(counterLabel)
        contentView.addSubview(toggleButton)

        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Dimen.x3),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Dimen.x3),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: Dimen.x6),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: Dimen.x6),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Dimen.x3),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Dimen.x3),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -Dimen.x3),

            toggleButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: Dimen.x2),
            toggleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Dimen.x3),
            toggleButton.widthAnchor.constraint(equalToConstant: Dimen.x9),
            toggleButton.heightAnchor.constraint(equalToConstant: Dimen.x9),
            toggleButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Dimen.x3),
            counterLabel.trailingAnchor.constraint(lessThanOrEqualTo: toggleButton.leadingAnchor, constant: -Dimen.x3),
            counterLabel.centerYAnchor.constraint(equalTo: toggleButton.centerYAnchor)
        ])
    }

    func setupActions() {
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
    }

    @objc func toggleTapped() {
        onToggle?()
    }

    static func daysString(for count: Int) -> String {
        let lastTwoDigits = count % 100
        let lastDigit = count % 10

        if (11...14).contains(lastTwoDigits) {
            return "дней"
        }

        switch lastDigit {
        case 1:
            return "день"
        case 2...4:
            return "дня"
        default:
            return "дней"
        }
    }
}
