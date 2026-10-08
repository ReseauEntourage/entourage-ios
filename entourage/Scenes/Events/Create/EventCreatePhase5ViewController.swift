//
//  EventCreatePhase5ViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//
//  Étape 5 « Partagez dans vos groupes » : zéro, un ou plusieurs groupes.
//

import UIKit
import SwiftUI

class EventCreatePhase5ViewController: UIViewController {

    weak var pageDelegate: EventCreateMainDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        guard let store = pageDelegate?.formStore else { return }

        let viewModel = EventCreatePhase5ViewModel(store: store)
        embedSwiftUI(EventStepGroupsView(store: store, viewModel: viewModel))
        viewModel.load()
    }
}

// MARK: - ViewModel -

final class EventCreatePhase5ViewModel: ObservableObject {
    @Published var groups = [Neighborhood]()
    @Published var isLoading = true
    private weak var store: EventFormStore?

    init(store: EventFormStore) {
        self.store = store
    }

    func load() {
        guard let me = UserDefaults.currentUser else {
            isLoading = false
            return
        }
        NeighborhoodService.getNeighborhoodsForUserId("\(me.sid)", currentPage: 1, per: 100) { [weak self] groups, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                guard let groups = groups else { return }
                self.groups = groups
                self.fillSelectedNames()
            }
        }
    }

    /// Les groupes pré-sélectionnés (depuis la page d'un groupe, ou un brouillon) n'ont pas toujours leur nom.
    private func fillSelectedNames() {
        guard let store = store else { return }
        let names = Dictionary(groups.map { ($0.uid, $0.name) }, uniquingKeysWith: { first, _ in first })
        let updated = store.values.groups.map { group -> EventNeighborhood in
            guard let name = names[group.id], name != group.name else { return group }
            return EventNeighborhood(id: group.id, name: name)
        }
        if updated != store.values.groups {
            store.update { $0.groups = updated }
        }
    }
}

// MARK: - Vue SwiftUI -

struct EventStepGroupsView: View {
    @ObservedObject var store: EventFormStore
    @ObservedObject var viewModel: EventCreatePhase5ViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                EventStepHeader(step: .groups)

                EventFormLabel(title: "event_form_groups_label".localized)
                    .padding(.bottom, -2)
                EventFormHint(text: "event_form_groups_hint".localized)

                if viewModel.isLoading {
                    HStack { Spacer(); ActivityIndicator(); Spacer() }
                        .padding(.top, 24)
                }
                else if viewModel.groups.isEmpty {
                    Text("event_form_groups_empty".localized)
                        .font(EventFormStyle.regular(14))
                        .foregroundColor(EventFormStyle.ink2)
                        .padding(.top, 8)
                }
                else {
                    ForEach(viewModel.groups, id: \.uid) { group in
                        groupRow(group)
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

    private func groupRow(_ group: Neighborhood) -> some View {
        let isOn = store.isGroupSelected(group.uid)
        return Button(action: { store.toggleGroup(id: group.uid, name: group.name) }) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text(group.name)
                        .font(EventFormStyle.regular(14))
                        .foregroundColor(EventFormStyle.ink)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 8)
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(isOn ? EventFormStyle.ink : Color.white)
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(isOn ? EventFormStyle.ink : EventFormStyle.line, lineWidth: 1.8)
                        if isOn {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 24, height: 24)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 2)
                .contentShape(Rectangle())
                Rectangle().fill(EventFormStyle.line2).frame(height: 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(addTraits: isOn ? [.isButton, .isSelected] : [.isButton])
    }
}

/// Indicateur de chargement compatible iOS 14.
private struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .medium)
        view.startAnimating()
        return view
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
}
