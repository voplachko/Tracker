//
//  TrackerCreationViewModel.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 24.06.2026.
//

import UIKit

enum CreationRow: Equatable {
    case category
    case schedule

    var title: String {
        switch self {
        case .category: return L10n.TrackerCreation.category
        case .schedule: return L10n.TrackerCreation.schedule
        }
    }
}

final class TrackerCreationViewModel {

    let titleCharacterLimit = 38

    // MARK: - Bindings

    var onCreateEnabledChanged: Binding<Bool>?
    var onCategoryChanged: Binding<String?>?
    var onScheduleChanged: Binding<String?>?
    var onLimitWarningChanged: Binding<Bool>?

    // MARK: - State

    let kind: TrackerKind

    private(set) var title = "" {
        didSet { refreshState() }
    }
    private(set) var selectedCategoryTitle: String? {
        didSet { onCategoryChanged?(selectedCategoryTitle); refreshState() }
    }
    private(set) var selectedSchedule: Set<WeekDay> = [] {
        didSet { onScheduleChanged?(scheduleSubtitle); refreshState() }
    }
    private(set) var selectedEmoji: String? {
        didSet { refreshState() }
    }
    private(set) var selectedColor: UIColor? {
        didSet { refreshState() }
    }

    private let editingTracker: Tracker?
    /// Дата, выбранная в календаре на главном экране: на неё назначается нерегулярное событие.
    private let selectedDate: Date
    let daysCount: Int?

    var isEditing: Bool { editingTracker != nil }

    // MARK: - Init

    init(kind: TrackerKind, selectedDate: Date) {
        self.kind = kind
        self.selectedDate = selectedDate
        self.editingTracker = nil
        self.daysCount = nil
    }

    init(editing tracker: Tracker, categoryTitle: String, daysCount: Int) {
        // При редактировании тип трекера сохраняется
        self.kind = tracker.kind
        self.selectedDate = tracker.eventDate ?? Date()
        self.editingTracker = tracker
        self.daysCount = daysCount
        self.title = tracker.title
        self.selectedCategoryTitle = categoryTitle
        self.selectedSchedule = tracker.schedule
        self.selectedEmoji = tracker.emoji
        self.selectedColor = tracker.color
    }

    // MARK: - Derived data for View

    var screenTitle: String {
        switch (isEditing, kind) {
        case (true, .habit): return L10n.TrackerCreation.editHabit
        case (true, .irregularEvent): return L10n.TrackerCreation.editIrregularEvent
        case (false, .habit): return L10n.TrackerCreation.newHabit
        case (false, .irregularEvent): return L10n.TrackerCreation.newIrregularEvent
        }
    }

    var actionButtonTitle: String {
        isEditing ? L10n.Common.save : L10n.Common.create
    }

    var daysCountText: String? {
        guard let daysCount else { return nil }
        return L10n.daysCount(daysCount)
    }

    var rows: [CreationRow] {
        switch kind {
        case .habit: return [.category, .schedule]
        case .irregularEvent: return [.category]
        }
    }

    var categorySubtitle: String? {
        selectedCategoryTitle
    }

    var scheduleSubtitle: String? {
        guard !selectedSchedule.isEmpty else { return nil }
        if selectedSchedule.count == WeekDay.allCases.count { return L10n.TrackerCreation.everyDay }
        return WeekDay.allCases
            .filter { selectedSchedule.contains($0) }
            .map { $0.shortTitle }
            .joined(separator: ", ")
    }

    // MARK: - User intent

    func updateTitle(_ text: String) {
        title = text
        onLimitWarningChanged?(isTitleTooLong)
    }

    func setCategory(_ title: String) {
        selectedCategoryTitle = title
    }

    func setSchedule(_ schedule: Set<WeekDay>) {
        selectedSchedule = schedule
    }

    func setEmoji(_ emoji: String?) {
        selectedEmoji = emoji
    }

    func setColor(_ color: UIColor?) {
        selectedColor = color
    }

    func makeCategoriesViewModel() -> CategoriesViewModel {
        CategoriesViewModel(selectedCategoryTitle: selectedCategoryTitle)
    }

    func makeTracker() -> (tracker: Tracker, categoryTitle: String)? {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !trimmedTitle.isEmpty,
            trimmedTitle.count <= titleCharacterLimit,
            let emoji = selectedEmoji,
            let color = selectedColor,
            let categoryTitle = selectedCategoryTitle
        else {
            return nil
        }

        let schedule: Set<WeekDay>
        let eventDate: Date?

        switch kind {
        case .habit:
            guard !selectedSchedule.isEmpty else { return nil }
            schedule = selectedSchedule
            eventDate = nil
        case .irregularEvent:
            // Событие привязано к дате создания, а не к дням недели
            schedule = []
            eventDate = editingTracker?.eventDate ?? selectedDate
        }

        let tracker = Tracker(
            id: editingTracker?.id ?? UUID(),
            title: trimmedTitle,
            color: color,
            emoji: emoji,
            schedule: schedule,
            eventDate: eventDate,
            isPinned: editingTracker?.isPinned ?? false
        )
        return (tracker, categoryTitle)
    }

    // MARK: - Validation

    var isTitleTooLong: Bool {
        title.count > titleCharacterLimit
    }

    private var isCreateEnabled: Bool {
        let hasTitle = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasValidLength = title.count <= titleCharacterLimit
        let hasSchedule = kind == .irregularEvent || !selectedSchedule.isEmpty
        let hasCategory = selectedCategoryTitle != nil
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColor != nil
        return hasTitle && hasValidLength && hasSchedule && hasCategory && hasEmoji && hasColor
    }

    private func refreshState() {
        onCreateEnabledChanged?(isCreateEnabled)
    }

    func refresh() {
        onCategoryChanged?(selectedCategoryTitle)
        onScheduleChanged?(scheduleSubtitle)
        onLimitWarningChanged?(isTitleTooLong)
        onCreateEnabledChanged?(isCreateEnabled)
    }
}
