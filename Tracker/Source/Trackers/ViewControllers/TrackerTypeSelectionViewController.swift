//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit

final class TrackerTypeSelectionViewController: UIViewController {

    var onTypeSelected: ((TrackerKind) -> Void)?

    private let viewModel = TrackerTypeSelectionViewModel()

    private lazy var habitButton = PrimaryButton(title: viewModel.habitTitle)
    private lazy var irregularEventButton = PrimaryButton(title: viewModel.irregularEventTitle)

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
        bindViewModel()
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

    func bindViewModel() {
        viewModel.onTypeSelected = { [weak self] kind in
            self?.onTypeSelected?(kind)
        }
    }

    @objc func habitTapped() {
        viewModel.selectHabit()
    }

    @objc func irregularEventTapped() {
        viewModel.selectIrregularEvent()
    }
}
