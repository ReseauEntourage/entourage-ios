//
//  EventCreatePhase2ViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//
//  Étape 2 « Quand a lieu votre événement ? » : date, heures de début et de fin, récurrence.
//

import UIKit
import SwiftUI

class EventCreatePhase2ViewController: UIViewController {

    weak var pageDelegate: EventCreateMainDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        guard let delegate = pageDelegate else { return }

        // La récurrence est réservée aux utilisateurs autorisés (rôles non vides) et
        // masquée quand on modifie un événement déjà récurrent (on ne change alors que la date).
        let userHasNoRole = UserDefaults.currentUser?.roles?.isEmpty ?? false
        let isRecurrenceHidden = delegate.hasCurrentRecurrency() || userHasNoRole

        embedSwiftUI(EventStepScheduleView(
            store: delegate.formStore,
            isRecurrenceHidden: isRecurrenceHidden,
            dateBounds: { [weak delegate] in
                guard let delegate = delegate else { return (nil, nil) }
                return EventStepScheduleView.dateBounds(
                    isEditingRecurrentEvent: delegate.hasCurrentRecurrency(),
                    initial: delegate.initialFormValues()
                )
            }
        ))
    }
}

// MARK: - Vue SwiftUI -

struct EventStepScheduleView: View {
    @ObservedObject var store: EventFormStore
    let isRecurrenceHidden: Bool
    let dateBounds: () -> (min: Date?, max: Date?)

    /// Création : à partir d'aujourd'hui. Modification d'un événement récurrent : la date ne peut
    /// bouger que dans l'intervalle de sa récurrence (comme avant la refonte).
    static func dateBounds(isEditingRecurrentEvent: Bool, initial: EventFormValues) -> (min: Date?, max: Date?) {
        let calendar = Calendar.current
        guard isEditingRecurrentEvent, let day = initial.day else {
            return (calendar.startOfDay(for: Date()), nil)
        }
        let days: Int
        switch initial.recurrence {
        case .week: days = 6
        case .every2Weeks: days = 13
        default: days = 0
        }
        return (calendar.date(byAdding: .day, value: -days, to: day), calendar.date(byAdding: .day, value: days, to: day))
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.getPreferredLocale()
        formatter.dateFormat = "dd / MM / yyyy"
        return formatter
    }()

    private func timeText(_ minutes: Int?) -> String {
        guard let minutes = minutes else { return "" }
        return String(format: "%02d : %02d", minutes / 60, minutes % 60)
    }

    private func date(atMinutes minutes: Int) -> Date {
        let day = store.values.day ?? Date()
        return Calendar.current.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: day) ?? day
    }

    private var recurrenceOptions: [EventRecurrence] {
        var options: [EventRecurrence] = [.once, .week, .every2Weeks]
        if store.values.recurrence == .month { options.append(.month) }
        return options
    }

    var body: some View {
        let bounds = dateBounds()
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                EventStepHeader(step: .schedule)

                // Date
                VStack(alignment: .leading, spacing: 0) {
                    EventFormLabel(title: "event_form_date_label".localized, isRequired: true)
                    EventPickerField(
                        mode: .date,
                        placeholder: "event_form_date_placeholder".localized,
                        text: store.values.day.map { Self.dayFormatter.string(from: $0) } ?? "",
                        trailingSystemImage: "calendar",
                        hasError: store.errors[.date] != nil,
                        defaultDate: bounds.min ?? Date(),
                        currentDate: store.values.day,
                        minimumDate: bounds.min,
                        maximumDate: bounds.max,
                        onCommit: { store.setDay($0) }
                    )
                    .eventFormError(store.errors[.date])
                }
                .padding(.bottom, 20)

                // Heures
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 0) {
                            EventFormLabel(title: "event_create_phase2_time_start".localized)
                            EventPickerField(
                                mode: .time,
                                placeholder: "event_form_time_placeholder".localized,
                                text: timeText(store.values.startMinutes),
                                trailingSystemImage: "clock",
                                hasError: store.errors[.timeStart] != nil,
                                defaultDate: date(atMinutes: 18 * 60),
                                currentDate: store.values.startMinutes.map { date(atMinutes: $0) },
                                onCommit: { picked in
                                    let minutes = EventFormStore.minutes(of: picked)
                                    store.update { $0.startMinutes = minutes }
                                }
                            )
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            EventFormLabel(title: "event_create_phase2_time_end".localized)
                            EventPickerField(
                                mode: .time,
                                placeholder: "event_form_time_placeholder".localized,
                                text: timeText(store.values.endMinutes),
                                trailingSystemImage: "clock",
                                hasError: store.errors[.timeEnd] != nil,
                                defaultDate: date(atMinutes: min((store.values.startMinutes ?? 18 * 60) + 180, 23 * 60 + 59)),
                                currentDate: store.values.endMinutes.map { date(atMinutes: $0) },
                                onCommit: { picked in
                                    let minutes = EventFormStore.minutes(of: picked)
                                    store.update { $0.endMinutes = minutes }
                                }
                            )
                        }
                    }
                    if let message = store.errors[.timeStart] {
                        EventFormErrorText(message: message)
                    }
                    if let message = store.errors[.timeEnd] {
                        EventFormErrorText(message: message)
                    }
                }
                .padding(.bottom, 22)

                // Récurrence
                if !isRecurrenceHidden {
                    VStack(alignment: .leading, spacing: 0) {
                        EventFormLabel(title: "event_form_recurrence_label".localized)
                        let options = recurrenceOptions
                        ForEach(0..<options.count, id: \.self) { index in
                            EventRadioRow(
                                title: options[index].getDescription(),
                                isOn: store.values.recurrence == options[index],
                                showsSeparator: index < options.count - 1,
                                action: { store.update { $0.recurrence = options[index] } }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white)
    }
}
