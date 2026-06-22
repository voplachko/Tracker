//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit

final class TrackerTypeSelectionViewController: UIViewController {
    var onHabitSelected: (() -> Void)?
    var onIrregularEventSelected: (() -> Void)?

    private let habitButton = TrackerTypeButton(title: "Привычка")
    private let irregularEventButton = TrackerTypeButton(title: "Нерегулярное событие")

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [habitButton, irregularEventButton])
        stackView.axis = .vertical
        stackView.spacing = Dimen.x4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupActions()
    }
}

private extension TrackerTypeSelectionViewController {
    func setupView() {
        title = "Создание трекера"
        view.backgroundColor = .systemBackground
    }

    func setupConstraints() {
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Dimen.x5),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Dimen.x5),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    func setupActions() {
        habitButton.addTarget(self, action: #selector(habitTapped), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(irregularEventTapped), for: .touchUpInside)
    }

    @objc func habitTapped() {
        onHabitSelected?()
    }

    @objc func irregularEventTapped() {
        onIrregularEventSelected?()
    }
}

private final class TrackerTypeButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .ypMedium16
        backgroundColor = .ypBlackDay
        layer.cornerRadius = Dimen.x4
        translatesAutoresizingMaskIntoConstraints = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}
