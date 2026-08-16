//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 28.05.2026.
//

import UIKit

final class StatisticsViewController: UIViewController {

    private enum Constants {
        static let cardHeight: CGFloat = 90
        static let placeholderImageSize: CGFloat = 80
    }

    private let viewModel: StatisticsViewModel

    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - UI

    private let cardsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Dimen.x3
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .emptyStatistics)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Statistics.placeholder
        label.font = .ypMedium12
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var placeholderStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [placeholderImageView, placeholderLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Dimen.x2
        stackView.isHidden = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupNavigationBar()
        setupConstraints()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
}

// MARK: - Setup

private extension StatisticsViewController {
    func setupView() {
        view.backgroundColor = .systemBackground
    }

    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        title = viewModel.screenTitle
    }

    func setupConstraints() {
        view.addSubview(cardsStackView)
        view.addSubview(placeholderStackView)

        NSLayoutConstraint.activate([
            cardsStackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Dimen.x19
            ),
            cardsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Dimen.x4),
            cardsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Dimen.x4),

            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: Constants.placeholderImageSize),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Constants.placeholderImageSize)
        ])
    }

    func bindViewModel() {
        viewModel.onStatisticsChanged = { [weak self] items in
            self?.showStatistics(items)
        }

        viewModel.onPlaceholderVisibilityChanged = { [weak self] shouldShowPlaceholder in
            self?.placeholderStackView.isHidden = !shouldShowPlaceholder
            self?.cardsStackView.isHidden = shouldShowPlaceholder
        }
    }

    func showStatistics(_ items: [StatisticItem]) {
        cardsStackView.arrangedSubviews.forEach {
            cardsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        items.forEach { item in
            let cardView = StatisticCardView()
            cardView.configure(with: item)
            cardView.heightAnchor.constraint(equalToConstant: Constants.cardHeight).isActive = true
            cardsStackView.addArrangedSubview(cardView)
        }
    }
}
