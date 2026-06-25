//
//  NewCategoryViewModel.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 24.06.2026.
//

import Foundation

final class NewCategoryViewModel {

    enum Mode {
        case create
        case edit(currentTitle: String)
    }

    var onReadyStateChanged: Binding<Bool>?
    var onCategoryReady: Binding<String>?

    private let mode: Mode

    private var title: String {
        didSet { onReadyStateChanged?(isReady) }
    }

    init(mode: Mode = .create) {
        self.mode = mode
        switch mode {
        case .create:
            title = ""
        case .edit(let currentTitle):
            title = currentTitle
        }
    }

    var screenTitle: String {
        switch mode {
        case .create: return "Новая категория"
        case .edit: return "Редактирование категории"
        }
    }

    var initialTitle: String { title }

    func viewDidLoad() {
        onReadyStateChanged?(isReady)
    }

    func updateTitle(_ text: String) {
        title = text
    }

    func done() {
        guard isReady else { return }
        onCategoryReady?(trimmedTitle)
    }

    private var isReady: Bool {
        !trimmedTitle.isEmpty
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
