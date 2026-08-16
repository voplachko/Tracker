//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit

final class TrackerCreationViewController: UIViewController {

    private enum Constants {
        static let rowHeight: CGFloat = 75
        static let textFieldHeight: CGFloat = 75
        static let buttonsHeight: CGFloat = 60
        static let cellReuseIdentifier = "CreationCell"
    }

    var onCreate: ((Tracker, String) -> Void)?
    var onSave: ((Tracker, String) -> Void)?

    private let viewModel: TrackerCreationViewModel

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
        textField.placeholder = L10n.TrackerCreation.titlePlaceholder
        textField.font = .ypRegular17
        textField.backgroundColor = .ypBackground
        textField.tintColor = .ypGray
        textField.layer.cornerRadius = Dimen.x4
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Dimen.x4, height: 1))
        textField.leftViewMode = .always
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var limitLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.TrackerCreation.characterLimit(viewModel.titleCharacterLimit)
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

    private lazy var daysCounterLabel: UILabel = {
        let label = UILabel()
        label.font = .ypBold32
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emojiPickerView = EmojiPickerView()
    private let colorPickerView = ColorPickerView()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.Common.cancel, for: .normal)
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
        button.backgroundColor = .ypGray
        button.setTitle(L10n.Common.create, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .ypMedium16
        button.layer.cornerRadius = Dimen.x4
        button.isEnabled = false
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

    init(kind: TrackerKind, selectedDate: Date) {
        self.viewModel = TrackerCreationViewModel(kind: kind, selectedDate: selectedDate)
        super.init(nibName: nil, bundle: nil)
    }

    init(editing tracker: Tracker, categoryTitle: String, daysCount: Int) {
        self.viewModel = TrackerCreationViewModel(
            editing: tracker,
            categoryTitle: categoryTitle,
            daysCount: daysCount
        )
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
        bindViewModel()
        populateInitialState()
        setupKeyboardDismiss()
        observeKeyboard()
    }
}

// MARK: - Setup

private extension TrackerCreationViewController {
    func setupView() {
        title = viewModel.screenTitle
        view.backgroundColor = .systemBackground
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
    }

    func setupPickers() {
        emojiPickerView.onSelectionChange = { [weak self] in
            self?.viewModel.setEmoji(self?.emojiPickerView.selectedEmoji)
        }
        colorPickerView.onSelectionChange = { [weak self] in
            self?.viewModel.setColor(self?.colorPickerView.selectedColor)
        }
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

        let titleFieldTopConstraint: NSLayoutConstraint
        if viewModel.isEditing {
            contentView.addSubview(daysCounterLabel)
            NSLayoutConstraint.activate([
                daysCounterLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Dimen.x6),
                daysCounterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Dimen.x4),
                daysCounterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Dimen.x4)
            ])
            titleFieldTopConstraint = titleTextField.topAnchor.constraint(
                equalTo: daysCounterLabel.bottomAnchor,
                constant: Dimen.x10
            )
        } else {
            titleFieldTopConstraint = titleTextField.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Dimen.x6
            )
        }

        NSLayoutConstraint.activate([
            titleFieldTopConstraint,
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -Dimen.x4),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Dimen.x4),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Dimen.x4),
            titleTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),

            limitLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: Dimen.x1),
            limitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            tableViewTopConstraint!,
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Dimen.x4),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Dimen.x4),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(viewModel.rows.count) * Constants.rowHeight),

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

    func populateInitialState() {
        createButton.setTitle(viewModel.actionButtonTitle, for: .normal)

        if viewModel.isEditing {
            titleTextField.text = viewModel.title
            daysCounterLabel.text = viewModel.daysCountText
            emojiPickerView.select(emoji: viewModel.selectedEmoji)
            colorPickerView.select(color: viewModel.selectedColor)
        }

        viewModel.refresh()
    }

    func bindViewModel() {
        viewModel.onCreateEnabledChanged = { [weak self] isEnabled in
            self?.createButton.isEnabled = isEnabled
            self?.createButton.backgroundColor = isEnabled ? .ypBlack : .ypGray
        }

        viewModel.onCategoryChanged = { [weak self] _ in
            self?.tableView.reloadData()
        }

        viewModel.onScheduleChanged = { [weak self] _ in
            self?.tableView.reloadData()
        }

        viewModel.onLimitWarningChanged = { [weak self] isExceeded in
            guard let self else { return }
            self.limitLabel.isHidden = !isExceeded
            self.updateLayoutForLimitLabel()
        }
    }
}

// MARK: - Layout helpers

private extension TrackerCreationViewController {
    func updateLayoutForLimitLabel() {
        let anchorView = limitLabel.isHidden ? titleTextField : limitLabel

        tableViewTopConstraint?.isActive = false
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: anchorView.bottomAnchor, constant: Dimen.x6)
        tableViewTopConstraint?.isActive = true

        guard view.window != nil else { return }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Actions

private extension TrackerCreationViewController {
    @objc func textFieldChanged() {
        viewModel.updateTitle(titleTextField.text ?? "")
    }

    @objc func cancelTapped() {
        dismiss(animated: true)
    }

    @objc func createTapped() {
        guard let result = viewModel.makeTracker() else { return }
        if viewModel.isEditing {
            onSave?(result.tracker, result.categoryTitle)
        } else {
            onCreate?(result.tracker, result.categoryTitle)
        }
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

// MARK: - UITextFieldDelegate

/// Длина названия не ограничивается на уровне ввода: при превышении лимита
/// показывается предупреждение «Ограничение 38 символов», а кнопка сохранения
/// становится неактивной.
extension TrackerCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource

extension TrackerCreationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = viewModel.rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = row.title
        content.textProperties.font = .ypRegular16

        switch row {
        case .category:
            content.secondaryText = viewModel.categorySubtitle
        case .schedule:
            content.secondaryText = viewModel.scheduleSubtitle
        }
        content.secondaryTextProperties.font = .ypRegular17
        content.secondaryTextProperties.color = .ypGray

        cell.contentConfiguration = content
        cell.backgroundColor = .ypBackground
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none

        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        cell.separatorInset = isLastCell
        ? UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        : UIEdgeInsets(top: 0, left: Dimen.x4, bottom: 0, right: Dimen.x4)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension TrackerCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel.rows[indexPath.row] {
        case .category:
            showCategories()
        case .schedule:
            showSchedule()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.rowHeight
    }
}

// MARK: - Navigation

private extension TrackerCreationViewController {
    func showCategories() {
        let categoriesViewModel = viewModel.makeCategoriesViewModel()
        let categoriesViewController = CategoriesViewController(viewModel: categoriesViewModel)
        categoriesViewController.onCategorySelect = { [weak self] title in
            self?.viewModel.setCategory(title)
        }
        navigationController?.pushViewController(categoriesViewController, animated: true)
    }

    func showSchedule() {
        let scheduleViewModel = ScheduleViewModel(selectedDays: viewModel.selectedSchedule)
        let scheduleViewController = ScheduleViewController(viewModel: scheduleViewModel)
        scheduleViewController.onScheduleSelected = { [weak self] schedule in
            self?.viewModel.setSchedule(schedule)
        }
        navigationController?.pushViewController(scheduleViewController, animated: true)
    }
}
