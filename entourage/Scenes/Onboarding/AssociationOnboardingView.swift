// AssociationOnboardingView.swift
import SwiftUI
import CoreLocation

enum AssociationOnboardingSelection {
    case existing(name: String)
    case other(name: String)
}

private extension Font {
    static func entourageTitle(_ size: CGFloat = 20) -> Font {
        .custom("Quicksand-Bold", size: size)
    }
    static func entourageBody(_ size: CGFloat = 15) -> Font {
        .custom("NunitoSans-Regular", size: size)
    }
}

struct AssociationOnboardingView: View {
    let associations: [String]
    let onBack: () -> Void
    let onValidate: (AssociationOnboardingSelection) -> Void

    @State private var selectedAssociation: String? = nil
    @State private var otherName: String = ""
    @State private var errorMessage: String? = nil

    private var isOtherSelected: Bool {
        selectedAssociation?.caseInsensitiveCompare("Autre") == .orderedSame
    }

    private var canValidate: Bool {
        guard let picked = selectedAssociation, !picked.isEmpty else { return false }
        if isOtherSelected {
            return !otherName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }

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
                VStack(alignment: .leading, spacing: 0) {
                    // Titre aligné à gauche
                    Text(NSLocalizedString("onboard_asso_title", comment: ""))
                        .font(.entourageTitle(20))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)

                    // Sous-titre aligné à gauche, 20 points en dessous du titre
                    Text(NSLocalizedString("onboard_asso_subtitle", comment: ""))
                        .font(.entourageBody(15))
                        .foregroundColor(Color(UIColor.appGrey151))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)

                    // Sélecteur aligné à gauche, 5 points en dessous du sous-titre
                    dropdownSection
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 5)

                    if isOtherSelected {
                        otherAssociationCard
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
            }

            if let error = errorMessage {
                Text(error)
                    .font(.entourageBody(15))
                    .foregroundColor(.red)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }

            bottomBar
        }
        .background(Color(UIColor.systemBackground))
        .ignoresSafeArea(edges: .bottom)
    }

    private var dropdownSection: some View {
        VStack(alignment: .leading, spacing: 6) {
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
                        .foregroundColor(selectedAssociation == nil ? Color(UIColor.appGrey151) : .black)
                        .font(.entourageBody(15))

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(UIColor.appGrey151))
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(UIColor.appPaleGrey), lineWidth: 1)
                        .background(Color.white.cornerRadius(8))
                )
            }
        }
    }

    private var otherAssociationCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(Color(UIColor.appOrange))

            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("onboard_asso_info", comment: ""))
                    .font(.entourageBody(15))
                    .foregroundColor(.black)

                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("onboard_asso_other_label", comment: ""))
                        .font(.entourageBody(15))
                        .foregroundColor(.black)

                    TextField(NSLocalizedString("onboard_asso_other_placeholder", comment: ""), text: $otherName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 8)
                        .frame(height: 40)
                        .font(.entourageBody(15))
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(UIColor.appPaleGrey), lineWidth: 1)
                        )
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 1.0, green: 0.95, blue: 0.9))
        )
        .padding(.top, 20)
    }

    private var bottomBar: some View {
        HStack(spacing: 8) {
            Button(action: onBack) {
                Text(NSLocalizedString("previous", comment: ""))
                    .font(.entourageBody(15))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 47)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(UIColor.appOrange), lineWidth: 1)
                            .background(Color.clear)
                    )
            }

            Button(action: validateTapped) {
                Text(NSLocalizedString("next", comment: ""))
                    .font(.entourageBody(15))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 47)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(canValidate ? Color(UIColor.appOrange) : Color(UIColor.appOrangeLight ?? .lightGray))
                    )
            }
            .disabled(!canValidate)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
    }

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

// AssociationOnboardingViewController.swift
import UIKit
import SwiftUI

final class AssociationOnboardingViewController: UIViewController {

    private var hostingController: UIHostingController<AssociationOnboardingView>?
    private var partners: [Partner] = []

    private let initialAddress: String?
    private let initialCoordinate: CLLocationCoordinate2D?

    init(initialAddress: String? = nil, initialCoordinate: CLLocationCoordinate2D? = nil) {
        self.initialAddress = initialAddress
        self.initialCoordinate = initialCoordinate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.initialAddress = nil
        self.initialCoordinate = nil
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        AnalyticsLoggerManager.logEvent(name: Onboard_asso_view)
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        loadAssociations()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func loadAssociations() {
        AssociationService.getAllAssociations { [weak self] associations, _ in
            guard let self = self else { return }

            self.partners = associations ?? []

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

    private func handleBack() {
        AnalyticsLoggerManager.logEvent(name: Onboard_asso_click_back)
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    private func handleValidate(selection: AssociationOnboardingSelection) {
        AnalyticsLoggerManager.logEvent(name: Onboard_asso_click_next)
        switch selection {
        case .existing(let name):
            guard let partner = partners.first(where: { $0.name == name }),
                  let partnerId = partner.aid else {
                goToOnboardingEnd()
                return
            }

            AssociationService.joinAssociation(
                partnerId: partnerId,
                postalCode: partner.postalCode,
                userRoleTitle: partner.userRoleTitle
            ) { [weak self] _ in
                self?.goToOnboardingEnd()
            }

        case .other(let customName):
            let lat = initialCoordinate?.latitude
            let lon = initialCoordinate?.longitude

            AssociationService.createAssociation(
                name: customName,
                address: initialAddress,
                latitude: lat,
                longitude: lon
            ) { [weak self] _, _ in
                self?.goToOnboardingEnd()
            }
        }
    }

    private func goToOnboardingEnd() {
        let storyboard = UIStoryboard(name: StoryboardName.onboarding, bundle: nil)
        if let endVC = storyboard.instantiateViewController(withIdentifier: "OnboardingEndViewController") as? OnboardingEndViewController {
            if let nav = navigationController {
                nav.pushViewController(endVC, animated: true)
            } else {
                endVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                present(endVC, animated: true, completion: nil)
            }
        }
    }
}
