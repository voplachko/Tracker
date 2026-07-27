//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 23.06.2026.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    private let backgroundImage: UIImage
    private let titleText: String

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = titleText
        label.font = .ypBold32
        label.textColor = .ypBlackDay
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(backgroundImage: UIImage, title: String) {
        self.backgroundImage = backgroundImage
        self.titleText = title
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }

    private func setupConstraints() {
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Dimen.x4),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Dimen.x4),

            titleLabel.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -OnboardingLayout.titleBottomInset
            )
        ])
    }
}
