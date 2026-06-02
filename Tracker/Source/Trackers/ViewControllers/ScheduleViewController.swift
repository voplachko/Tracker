//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit

final class ScheduleViewController: UIViewController {
    var selectedDays: Set<WeekDay>
    var onScheduleSelected: ((Set<WeekDay>) -> Void)?

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

    init(selectedDays: Set<WeekDay>) {
        self.selectedDays = selectedDays
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(WeekDay.allCases.count) * 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Dimen.x5),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Dimen.x5),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Dimen.x4),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    func setupActions() {
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }

    @objc func switchChanged(_ sender: UISwitch) {
        let day = WeekDay.allCases[sender.tag]
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }

    @objc func doneTapped() {
        onScheduleSelected?(selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WeekDay.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.reuseIdentifier,
            for: indexPath
        ) as? ScheduleCell else {
            return UITableViewCell()
        }

        let day = WeekDay.allCases[indexPath.row]

        let daySwitch = UISwitch()
        daySwitch.tag = indexPath.row
        daySwitch.isOn = selectedDays.contains(day)
        daySwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)

        cell.textLabel?.text = day.title
        cell.textLabel?.font = .ypRegular17
        cell.backgroundColor = .ypBackgroundDay
        cell.selectionStyle = .none
        cell.accessoryView = daySwitch

        let isLastCell = indexPath.row == WeekDay.allCases.count - 1
        cell.separatorView.isHidden = isLastCell

        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
