import UIKit
import SwiftUI
import CoreLocation

enum AssociationOnboardingSelection {
    case existing(name: String)
    case other(name: String)
}

struct AssociationOnboardingView: View {
    let associations: [String]
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
                VStack(alignment: .leading, spacing: 16) {
                    Text(NSLocalizedString("onboard_asso_title", comment: ""))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 24)

                    Text(NSLocalizedString("onboard_asso_subtitle", comment: ""))
                        .font(.system(size: 14))
                        .foregroundColor(Color(UIColor.secondaryLabel))

                    dropdownSection

                    if isOtherSelected {
                        otherAssociationCard
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 22)
            }

            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .padding(.horizontal, 22)
                    .padding(.bottom, 4)
            }

            bottomBar
        }
        .background(Color(UIColor.systemBackground))
        .ignoresSafeArea(edges: .bottom)
    }

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

    private var otherAssociationCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.85, green: 0.45, blue: 0))

                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("onboard_asso_info", comment: ""))
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.42, green: 0.23, blue: 0))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(NSLocalizedString("onboard_asso_other_label", comment: ""))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)

                        TextField(NSLocalizedString("onboard_asso_other_placeholder", comment: ""), text: $otherName)
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
                .fill(Color(red: 1.0, green: 0.95, blue: 0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 1.0, green: 0.78, blue: 0.54), lineWidth: 1)
        )
        .padding(.top, 14)
    }

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
        view.backgroundColor = .systemBackground
        loadAssociations()
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
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    private func handleValidate(selection: AssociationOnboardingSelection) {
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
