//
//  EventCreatePhase4ViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//
//  Étape 4 « Quel type d'activité proposez-vous ? » : catégories en pastilles sélectionnables.
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
        // La catégorie « Autre » (et sa saisie libre) n'est plus proposée dans ce parcours.
        let tags = (Metadatas.sharedInstance.tagsInterest?.getTags() ?? [])
            .filter { $0.key != Tag.tagOther }
            .map { (key: $0.key, name: $0.name) }
        embedSwiftUI(EventStepCategoriesView(store: delegate.formStore, tags: tags))
    }
}

// MARK: - Vue SwiftUI -

struct EventStepCategoriesView: View {
    @ObservedObject var store: EventFormStore
    let tags: [(key: String, name: String)]

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
