//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 24.06.2026.
//

import UIKit

final class NewCategoryViewController: UIViewController {

    private enum Constants {
        static let fieldHeight: CGFloat = 75
        static let buttonHeight: CGFloat = 60
    }

    private let viewModel: NewCategoryViewModel

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
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

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .ypMedium16
        button.layer.cornerRadius = Dimen.x4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(viewModel: NewCategoryViewModel) {
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
        setupConstraints()
        setupActions()
        bindViewModel()
        titleTextField.text = viewModel.initialTitle
        viewModel.viewDidLoad()
    }
}

// MARK: - Setup

private extension NewCategoryViewController {
    func setupView() {
        title = viewModel.screenTitle
        view.backgroundColor = .systemBackground
        titleTextField.delegate = self
    }

    func setupConstraints() {
        view.addSubview(titleTextField)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Dimen.x6),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Dimen.x4),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Dimen.x4),
            titleTextField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Dimen.x5),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Dimen.x5),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Dimen.x4),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    func setupActions() {
        titleTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }

    func bindViewModel() {
        viewModel.onReadyStateChanged = { [weak self] isReady in
            self?.setReadyState(isReady)
        }
    }

    func setReadyState(_ isReady: Bool) {
        doneButton.isEnabled = isReady
        doneButton.backgroundColor = isReady ? .ypBlackDay : .ypGray
    }

    @objc func textChanged() {
        viewModel.updateTitle(titleTextField.text ?? "")
    }

    @objc func doneTapped() {
        viewModel.done()
    }
}

// MARK: - UITextFieldDelegate

extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
