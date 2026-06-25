//
//  CategoryCell.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 24.06.2026.
//

import UIKit

final class CategoryCell: UITableViewCell {

    static let reuseIdentifier = "CategoryCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .ypRegular17
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .ypBackgroundDay
        selectionStyle = .none
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func configure(with viewModel: CategoryCellViewModel) {
        titleLabel.text = viewModel.title
        checkmarkImageView.isHidden = !viewModel.isSelected
    }

    func setSeparatorHidden(_ isHidden: Bool) {
        separatorView.isHidden = isHidden
    }

    private func setupConstraints() {
        [titleLabel, checkmarkImageView, separatorView].forEach(contentView.addSubview)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Dimen.x4),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Dimen.x4),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: Dimen.x6),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: Dimen.x6),

            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: checkmarkImageView.leadingAnchor,
                constant: -Dimen.x2
            ),

            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Dimen.x4),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Dimen.x4),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
