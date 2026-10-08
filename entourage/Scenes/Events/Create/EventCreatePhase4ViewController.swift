//
//  EventCreatePhase4ViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//
//  Étape 4 « De quoi allez-vous parler ? » : catégories en pastilles sélectionnables.
//

import UIKit
import SwiftUI

class EventCreatePhase4ViewController: UIViewController {

    weak var pageDelegate: EventCreateMainDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        guard let delegate = pageDelegate else { return }

        // Les catégories sont celles de l'app (Metadatas) ; la sélection vit dans le formulaire.
        let tags = (Metadatas.sharedInstance.tagsInterest?.getTags() ?? []).map { (key: $0.key, name: $0.name) }
        embedSwiftUI(EventStepCategoriesView(store: delegate.formStore, tags: tags, allowsOtherMessage: !delegate.isEdit()))
    }
}

// MARK: - Vue SwiftUI -

struct EventStepCategoriesView: View {
    @ObservedObject var store: EventFormStore
    let tags: [(key: String, name: String)]
    /// En modification, la précision de la catégorie « Autre » n'est pas éditable (comme avant la refonte).
    let allowsOtherMessage: Bool

    private func name(for key: String) -> String {
        return tags.first { $0.key == key }?.name ?? key
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                EventStepHeader(step: .categories)

                EventFormLabel(title: "event_form_categories_label".localized, isRequired: true)
                    .padding(.bottom, 6)

                EventFlowLayout(items: tags.map { $0.key }) { key in
                    EventChip(title: name(for: key), isOn: store.values.interests.contains(key)) {
                        store.toggleInterest(key)
                    }
                }
                .eventFormError(store.errors[.categories])

                if allowsOtherMessage && store.values.isOtherInterestSelected {
                    EventFormTextField(
                        placeholder: "event_form_category_other_placeholder".localized,
                        text: store.binding(\.otherInterestMessage),
                        hasError: store.errors[.otherCategory] != nil
                    )
                    .eventFormError(store.errors[.otherCategory])
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.onTapGesture { EventFormStyle.hideKeyboard() })
        }
        .background(Color.white)
    }
}
