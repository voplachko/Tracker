//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit

final class ScheduleViewController: UIViewController {
    private enum Constants {
        static let rowHeight: CGFloat = 75
        static let doneButtonHeight: CGFloat = 60
    }

    var onScheduleSelected: ((Set<WeekDay>) -> Void)?

    private let viewModel: ScheduleViewModel

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = Dimen.x4
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .ypMedium16
        button.backgroundColor = .ypBlackDay
        button.layer.cornerRadius = Dimen.x4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(viewModel: ScheduleViewModel) {
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
        setupActions()
    }
}

private extension ScheduleViewController {
    func setupView() {
        title = "Расписание"
        view.backgroundColor = .systemBackground
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            ScheduleCell.self,
            forCellReuseIdentifier: ScheduleCell.reuseIdentifier
        )
    }

    func setupConstraints() {
        view.addSubview(tableView)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Dimen.x6),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Dimen.x4),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Dimen.x4),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(viewModel.numberOfDays()) * Constants.rowHeight),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Dimen.x5),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Dimen.x5),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Dimen.x4),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.doneButtonHeight)
        ])
    }

    func setupActions() {
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }

    @objc func switchChanged(_ sender: UISwitch) {
        viewModel.setDay(at: sender.tag, isSelected: sender.isOn)
    }

    @objc func doneTapped() {
        onScheduleSelected?(viewModel.selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfDays()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.reuseIdentifier,
            for: indexPath
        ) as? ScheduleCell else {
            return UITableViewCell()
        }

        let daySwitch = UISwitch()
        daySwitch.tag = indexPath.row
        daySwitch.isOn = viewModel.isDaySelected(at: indexPath.row)
        daySwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)

        cell.textLabel?.text = viewModel.dayTitle(at: indexPath.row)
        cell.textLabel?.font = .ypRegular17
        cell.backgroundColor = .ypBackgroundDay
        cell.selectionStyle = .none
        cell.accessoryView = daySwitch

        let isLastCell = indexPath.row == viewModel.numberOfDays() - 1
        cell.separatorView.isHidden = isLastCell

        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.rowHeight
    }
}
