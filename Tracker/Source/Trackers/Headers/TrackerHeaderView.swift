//
//  TrackerHeaderView.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 01.06.2026.
//

import UIKit

final class TrackerHeaderView: UICollectionReusableView {
    static let reuseId = "TrackerHeaderView"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .ypBold19
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
}

private extension TrackerHeaderView {
    func setupView() {
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Dimen.x3),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: Dimen.x6)
        ])
    }
}
