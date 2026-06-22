//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 01.06.2026.
//

import UIKit

final class ScheduleCell: UITableViewCell {

    static let reuseIdentifier = "ScheduleCell"

    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(separatorView)

        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Dimen.x4
            ),
            separatorView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Dimen.x4
            ),
            separatorView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}
