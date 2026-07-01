//
//  SFSymbol.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 01.07.2026.
//

import UIKit

enum SFSymbol: String {
    case checkmark
    case pinFill = "pin.fill"
    case plus
}

extension UIImage {
    convenience init?(sfSymbol: SFSymbol, withConfiguration configuration: UIImage.Configuration? = nil) {
        self.init(systemName: sfSymbol.rawValue, withConfiguration: configuration)
    }
}
