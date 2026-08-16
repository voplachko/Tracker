//
//  SelectableCell.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 05.08.2026.
//

import UIKit

/// Строка списка с заголовком и синей галочкой у выбранного элемента.
final class SelectableCell: UITableViewCell {

    /// Положение строки в списке: от него зависят скругления и разделитель.
    enum Position {
        case single
        case first
        case middle
        case last

        init(row: Int, totalRows: Int) {
            switch (row, totalRows) {
            case (_, 1): self = .single
            case (0, _): self = .first
            case (totalRows - 1, _): self = .last
            default: self = .middle
            }
        }

        var maskedCorners: CACornerMask {
            switch self {
            case .single: return [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                  .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            case .first: return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            case .last: return [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            case .middle: return []
            }
        }

        var isSeparatorHidden: Bool {
            self == .single || self == .last
        }
    }

    static let reuseIdentifier = "SelectableCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .ypRegular17
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(sfSymbol: .checkmark))
        imageView.tintColor = .ypBlue
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
        backgroundColor = .ypBackground
        selectionStyle = .none
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func configure(with viewModel: SelectableCellViewModel, position: Position) {
        titleLabel.text = viewModel.title
        checkmarkImageView.isHidden = !viewModel.isSelected

        // Углы скругляются на уровне ячейки: таблица занимает всю доступную
        // высоту, поэтому её собственные границы не совпадают с границами списка.
        layer.cornerRadius = position.maskedCorners.isEmpty ? 0 : Dimen.x4
        layer.maskedCorners = position.maskedCorners
        layer.masksToBounds = true

        separatorView.isHidden = position.isSeparatorHidden
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
