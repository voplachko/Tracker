//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit

final class TrackerCreationViewController: UIViewController {
    enum TrackerKind {
        case habit
        case irregularEvent
    }

    enum CreationRow: Equatable {
        case category
        case schedule

        var title: String {
            switch self {
            case .category: return "Категория"
            case .schedule: return "Расписание"
            }
        }
    }

    private enum Constants {
        static let titleCharacterLimit = 38
        static let rowHeight: CGFloat = 75
        static let textFieldHeight: CGFloat = 75
        static let buttonsHeight: CGFloat = 60
        static let cellReuseIdentifier = "CreationCell"
    }

    var onCreate: ((Tracker) -> Void)?

    private let kind: TrackerKind
    private var selectedSchedule: Set<WeekDay> = [] {
        didSet { tableView.reloadData(); updateCreateButtonState() }
    }

    private var tableViewTopConstraint: NSLayoutConstraint?
    private var buttonsBottomConstraint: NSLayoutConstraint?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .ypRegular17
        textField.backgroundColor = .ypBackgroundDay
        textField.tintColor = .ypGray
        textField.layer.cornerRadius = Dimen.x4
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Dimen.x4, height: 1))
        textField.leftViewMode = .always
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let limitLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение \(Constants.titleCharacterLimit) символов"
        label.textColor = .ypRed
        label.font = .ypRegular17
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: Dimen.x4, bottom: 0, right: Dimen.x4)
        tableView.layer.cornerRadius = Dimen.x4
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let emojiPickerView = EmojiPickerView()
    private let colorPickerView = ColorPickerView()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = .ypMedium16
        button.layer.cornerRadius = Dimen.x4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .ypBlackDay
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .ypMedium16
        button.layer.cornerRadius = Dimen.x4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Dimen.x2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    init(kind: TrackerKind) {
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.delegate = self

        setupView()
        setupTableView()
        setupPickers()
        setupConstraints()
        setupActions()
        updateCreateButtonState()
        setupKeyboardDismiss()
        observeKeyboard()
    }
}

private extension TrackerCreationViewController {
    var rows: [CreationRow] {
        switch kind {
        case .habit:
            return [.category, .schedule]
        case .irregularEvent:
            return [.category]
        }
    }

    func setupView() {
        title = kind == .habit ? "Новая привычка" : "Новое нерегулярное событие"
        view.backgroundColor = .systemBackground
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
    }

    func setupPickers() {
        emojiPickerView.onSelectionChange = { [weak self] in self?.updateCreateButtonState() }
        colorPickerView.onSelectionChange = { [weak self] in self?.updateCreateButtonState() }
    }

    func setupConstraints() {
        view.addSubview(scrollView)
        view.addSubview(buttonsStackView)
        scrollView.addSubview(contentView)

        [
            titleTextField,
            limitLabel,
            tableView,
            emojiPickerView,
            colorPickerView
        ].forEach { contentView.addSubview($0) }

        tableViewTopConstraint = tableView.topAnchor.constraint(
            equalTo: titleTextField.bottomAnchor,
            constant: Dimen.x6
        )

        buttonsBottomConstraint = buttonsStackView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -Dimen.x4
        )

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -Dimen.x4),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Dimen.x6),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Dimen.x4),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Dimen.x4),
            titleTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),

            limitLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: Dimen.x1),
            limitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            tableViewTopConstraint!,
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Dimen.x4),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Dimen.x4),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(rows.count) * Constants.rowHeight),

            emojiPickerView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: Dimen.x8),
            emojiPickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiPickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            colorPickerView.topAnchor.constraint(equalTo: emojiPickerView.bottomAnchor, constant: Dimen.x4),
            colorPickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorPickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorPickerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Dimen.x4),

            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Dimen.x5),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Dimen.x5),
            buttonsBottomConstraint!,
            buttonsStackView.heightAnchor.constraint(equalToConstant: Constants.buttonsHeight)
        ])
    }

    func setupActions() {
        titleTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
    }

    func updateLayoutForLimitLabel() {
        let anchorView = limitLabel.isHidden ? titleTextField : limitLabel

        tableViewTopConstraint?.isActive = false
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: anchorView.bottomAnchor, constant: Dimen.x6)
        tableViewTopConstraint?.isActive = true

        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    func updateCreateButtonState() {
        let title = titleTextField.text ?? ""
        let hasTitle = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasSchedule = kind == .irregularEvent || !selectedSchedule.isEmpty
        let hasValidLength = title.count <= Constants.titleCharacterLimit
        let hasEmoji = emojiPickerView.selectedEmoji != nil
        let hasColor = colorPickerView.selectedColor != nil

        let isEnabled = hasTitle && hasSchedule && hasValidLength && hasEmoji && hasColor

        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .ypBlackDay : .ypGray
    }

    func scheduleSubtitle() -> String? {
        guard !selectedSchedule.isEmpty else { return nil }
        if selectedSchedule.count == WeekDay.allCases.count { return "Каждый день" }
        return WeekDay.allCases
            .filter { selectedSchedule.contains($0) }
            .map { $0.shortTitle }
            .joined(separator: ", ")
    }

    @objc func textFieldChanged() {
        updateLimitLabelState(for: titleTextField.text ?? "")
        updateCreateButtonState()
    }

    func updateLimitLabelState(for text: String) {
        let isExceeded = text.count > Constants.titleCharacterLimit
        limitLabel.isHidden = !isExceeded
        updateLayoutForLimitLabel()
    }

    @objc func cancelTapped() {
        dismiss(animated: true)
    }

    @objc func createTapped() {
        let trimmedTitle = (titleTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !trimmedTitle.isEmpty,
            let emoji = emojiPickerView.selectedEmoji,
            let color = colorPickerView.selectedColor
        else { return }

        let schedule: Set<WeekDay>

        switch kind {
        case .habit:
            guard !selectedSchedule.isEmpty else { return }
            schedule = selectedSchedule
        case .irregularEvent:
            schedule = Set(WeekDay.allCases)
        }

        let tracker = Tracker(
            id: UUID(),
            title: trimmedTitle,
            color: color,
            emoji: emoji,
            schedule: schedule
        )

        onCreate?(tracker)
        dismiss(animated: true)
    }

    func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )

        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    func observeKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboard(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc func handleKeyboard(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let endFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let endFrame = endFrameValue.cgRectValue
        let endFrameInView = view.convert(endFrame, from: view.window)
        let intersection = view.bounds.intersection(endFrameInView)
        let bottomSafe = view.safeAreaInsets.bottom
        let targetConstant: CGFloat = intersection.height > 0
        ? -(intersection.height - bottomSafe) - Dimen.x4
        : -Dimen.x4

        buttonsBottomConstraint?.constant = targetConstant

        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension TrackerCreationViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""

        guard let textRange = Range(range, in: currentText) else {
            return false
        }

        let updatedText = currentText.replacingCharacters(in: textRange, with: string)

        updateLayoutForLimitLabel()
        updateLimitLabelState(for: updatedText)

        return updatedText.count <= Constants.titleCharacterLimit
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension TrackerCreationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = row.title
        content.textProperties.font = .ypRegular16

        if row == .schedule {
            content.secondaryText = scheduleSubtitle()
            content.secondaryTextProperties.font = .ypRegular17
            content.secondaryTextProperties.color = .ypGray
        }

        cell.contentConfiguration = content
        cell.backgroundColor = .ypBackgroundDay
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none

        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        cell.separatorInset = isLastCell
        ? UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        : UIEdgeInsets(top: 0, left: Dimen.x4, bottom: 0, right: Dimen.x4)

        return cell
    }
}

extension TrackerCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard rows[indexPath.row] == .schedule else { return }

        let scheduleViewController = ScheduleViewController(selectedDays: selectedSchedule)
        scheduleViewController.onScheduleSelected = { [weak self] schedule in
            self?.selectedSchedule = schedule
        }
        navigationController?.pushViewController(scheduleViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.rowHeight
    }
}
