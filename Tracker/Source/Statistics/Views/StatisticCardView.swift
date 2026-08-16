//
//  StatisticCardView.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 05.08.2026.
//

import UIKit

/// Карточка показателя статистики с градиентной рамкой в 1pt.
final class StatisticCardView: UIView {

    private enum Constants {
        static let borderWidth: CGFloat = 1
    }

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .ypBold32
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .ypMedium12
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = UIColor.ypGradient.map { $0.cgColor }
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()

    private let borderMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = Constants.borderWidth
        return layer
    }()

    init() {
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds

        let insetBounds = bounds.insetBy(dx: Constants.borderWidth / 2, dy: Constants.borderWidth / 2)
        borderMaskLayer.path = UIBezierPath(
            roundedRect: insetBounds,
            cornerRadius: Dimen.x4
        ).cgPath
    }

    func configure(with item: StatisticItem) {
        valueLabel.text = String(item.value)
        titleLabel.text = item.title
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        gradientLayer.mask = borderMaskLayer
        layer.addSublayer(gradientLayer)

        addSubview(valueLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: Dimen.x3),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Dimen.x3),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Dimen.x3),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: Dimen.x2),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Dimen.x3),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Dimen.x3),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Dimen.x3)
        ])
    }
}
