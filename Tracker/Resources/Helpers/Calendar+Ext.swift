//
//  Calendar+Ext.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 01.06.2026.
//

import Foundation

extension Calendar {
    func isDateInFuture(_ date: Date) -> Bool {
        startOfDay(for: date) > startOfDay(for: Date())
    }
}
