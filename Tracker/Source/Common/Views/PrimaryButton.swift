//
//  PrimaryButton.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 23.06.2026.
//

import UIKit

final class PrimaryButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .ypMedium16
        backgroundColor = .ypBlackDay
        layer.cornerRadius = Dimen.x4
        translatesAutoresizingMaskIntoConstraints = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}
