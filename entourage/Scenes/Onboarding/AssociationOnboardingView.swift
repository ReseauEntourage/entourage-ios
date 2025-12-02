//
//  AssociationOnboardingView.swift
//  entourage
//
//  Created by Clement entourage on 01/12/2025.
//

import UIKit
import SwiftUI

// MARK: - Selection result from SwiftUI view

enum AssociationOnboardingSelection {
    case existing(name: String)
    case other(name: String)
}

/// Vue SwiftUI calquée sur le comportement Android:
/// - Titre / sous-titre
/// - Menu déroulant avec liste d'associations (premier élément = "Autre")
/// - Si "Autre" est choisi : bulle orange + TextField
/// - Validation avec contrôle (obligatoire de choisir, et texte requis si "Autre")
struct AssociationOnboardingView: View {
    let associations: [String]               // ex: ["Autre", "Croix Rouge", ...]
    let onBack: () -> Void
    let onValidate: (AssociationOnboardingSelection) -> Void

    @State private var selectedAssociation: String? = nil
    @State private var otherName: String = ""
    @State private var errorMessage: String? = nil

    private var firstItemAutre: String {
        associations.first ?? "Autre"
    }

    private var isOtherSelected: Bool {
        selectedAssociation?.caseInsensitiveCompare(firstItemAutre) == .orderedSame
    }

    private var canValidate: Bool {
        guard let picked = selectedAssociation, !picked.isEmpty else {
            return false
        }
        if isOtherSelected {
            return !otherName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }

    /// Nom final (pour "Autre" = texte saisie, sinon = nom de l'asso)
    private var finalAssociationName: String? {
        guard let picked = selectedAssociation, !picked.isEmpty else { return nil }
        if isOtherSelected {
            let trimmed = otherName.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        } else {
            return picked
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Titre
                    Text(NSLocalizedString("onboard_asso_title", comment: ""))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 24)

                    // Sous-titre
                    Text(NSLocalizedString("onboard_asso_subtitle", comment: ""))
                        .font(.system(size: 14))
                        .foregroundColor(Color(UIColor.secondaryLabel))

                    // Dropdown
                    dropdownSection

                    // Bulle "Autre"
                    if isOtherSelected {
                        otherAssociationCard
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 22)
            }

            // Erreur éventuelle
            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .padding(.horizontal, 22)
                    .padding(.bottom, 4)
            }

            // Bottom bar boutons
            bottomBar
        }
        .background(Color(UIColor.systemBackground))
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Dropdown

    private var dropdownSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(NSLocalizedString("onboard_asso_dropdown_hint", comment: ""))
                .font(.system(size: 13))
                .foregroundColor(.gray)

            Menu {
                ForEach(associations, id: \.self) { assoc in
                    Button(assoc) {
                        selectedAssociation = assoc
                        errorMessage = nil
                        if !isOtherSelected {
                            otherName = ""
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedAssociation ?? NSLocalizedString("onboard_asso_dropdown_hint", comment: ""))
                        .foregroundColor(selectedAssociation == nil ? .gray : .black)
                        .font(.system(size: 15))

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(UIColor.lightGray), lineWidth: 1)
                        .background(Color.white.cornerRadius(8))
                )
            }
        }
        .padding(.top, 18)
    }

    // MARK: - Card "Autre"

    private var otherAssociationCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.85, green: 0.45, blue: 0)) // proche orange

                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("onboard_asso_info", comment: ""))
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.42, green: 0.23, blue: 0)) // #6B3B00

                    VStack(alignment: .leading, spacing: 4) {
                        Text(NSLocalizedString("onboard_asso_other_label", comment: ""))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)

                        TextField(NSLocalizedString("onboard_asso_other_placeholder", comment: ""),
                                  text: $otherName)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 8)
                            .frame(height: 40)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(UIColor.lightGray), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 1.0, green: 0.95, blue: 0.9)) // #FFF3E5
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 1.0, green: 0.78, blue: 0.54), lineWidth: 1) // #FFC68A
        )
        .padding(.top, 14)
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        HStack(spacing: 8) {
            Button(action: onBack) {
                Text(NSLocalizedString("previous", comment: "Précédent"))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 47)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(UIColor.appOrange ?? .orange), lineWidth: 1)
                            .background(Color.clear)
                    )
            }

            Button(action: validateTapped) {
                Text(NSLocalizedString("next", comment: "Suivant"))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 47)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(canValidate ? Color(UIColor.appOrange ?? .orange) : Color(UIColor.appOrangeLight ?? .lightGray))
                    )
            }
            .disabled(!canValidate)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
    }

    // MARK: - Validate

    private func validateTapped() {
        guard let finalName = finalAssociationName else {
            if isOtherSelected {
                errorMessage = NSLocalizedString("onboard_asso_other_required", comment: "")
            } else {
                errorMessage = NSLocalizedString("onboard_asso_pick_first", comment: "")
            }
            return
        }

        errorMessage = nil

        if isOtherSelected {
            onValidate(.other(name: finalName))
        } else {
            onValidate(.existing(name: finalName))
        }
    }
}

// MARK: - UIViewController hosting SwiftUI

/// UIViewController qui héberge la vue SwiftUI et gère la navigation + appels backend.
final class AssociationOnboardingViewController: UIViewController {

    private var hostingController: UIHostingController<AssociationOnboardingView>?
    private var partners: [Partner] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        loadAssociations()
    }

    // MARK: - Load associations from API

    private func loadAssociations() {
        AssociationService.getAllAssociations { [weak self] associations, _ in
            guard let self = self else { return }

            self.partners = associations ?? []

            // On construit la liste de noms pour la vue.
            // Premier élément : "Autre" (comme sur Android / maquette)
            var names: [String] = ["Autre"]
            names.append(contentsOf: self.partners.map { $0.name })

            self.configureSwiftUIView(with: names)
        }
    }

    private func configureSwiftUIView(with associationNames: [String]) {
        let swiftUIView = AssociationOnboardingView(
            associations: associationNames,
            onBack: { [weak self] in
                self?.handleBack()
            },
            onValidate: { [weak self] selection in
                self?.handleValidate(selection: selection)
            }
        )

        let host = UIHostingController(rootView: swiftUIView)
        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        host.didMove(toParent: self)
        hostingController = host
    }

    // MARK: - Navigation

    private func handleBack() {
        // On revient à la zone (push navigation)
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Validate selection (join or create)

    private func handleValidate(selection: AssociationOnboardingSelection) {
        switch selection {
        case .existing(let name):
            // On retrouve le Partner correspondant
            guard let partner = partners.first(where: { $0.name == name }),
                  let partnerId = partner.aid else {
                // Si pas trouvé, on finit l’onboarding quand même (ou afficher une alerte selon ton choix)
                goToOnboardingEnd()
                return
            }

            AssociationService.joinAssociation(partnerId: partnerId,
                                               postalCode: partner.postalCode,
                                               userRoleTitle: partner.userRoleTitle) { [weak self] error in
                guard let self = self else { return }

                if error != nil {
                    // TODO: afficher une alerte si tu veux gérer l’erreur réseau
                    self.goToOnboardingEnd()
                } else {
                    self.goToOnboardingEnd()
                }
            }

        case .other(let customName):
            AssociationService.createAssociation(name: customName) { [weak self] _, _ in
                guard let self = self else { return }
                // On pourrait éventuellement rejoindre automatiquement cette asso,
                // mais côté backend ça peut déjà être le cas.
                self.goToOnboardingEnd()
            }
        }
    }

    private func goToOnboardingEnd() {
        let storyboard = UIStoryboard(name: StoryboardName.onboarding, bundle: nil)
        if let endVC = storyboard.instantiateViewController(withIdentifier: "OnboardingEndViewController") as? OnboardingEndViewController {
            if let nav = navigationController {
                nav.pushViewController(endVC, animated: true)
            } else {
                endVC.modalPresentationStyle = .fullScreen
                present(endVC, animated: true, completion: nil)
            }
        }
    }
}
