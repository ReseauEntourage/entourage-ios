import SwiftUI
import Combine
import CoreLocation
import GooglePlaces
import UIKit

// MARK: - Notification (écoutée par le StartController si besoin)
extension Notification.Name {
    static let onboardingPhase1CanProceedChanged = Notification.Name("onboardingPhase1CanProceedChanged")
}

// MARK: - Fonts SwiftUI (Quicksand‑Bold & NunitoSans‑Regular)
//
// Toutes les polices utilisées par les vues de l’onboarding sont
// centralisées ici afin de garantir une cohérence visuelle. Les titres
// utilisent Quicksand‑Bold en taille 20 et les textes utilisent
// NunitoSans‑Regular en taille 15.
private extension Font {
    static func entourageTitle(_ size: CGFloat = 20) -> Font {
        .custom("Quicksand-Bold", size: size)
    }
    static func entourageBody(_ size: CGFloat = 15) -> Font {
        .custom("NunitoSans-Regular", size: size)
    }
}

// MARK: - UIKit helpers (fermeture clavier globale iOS 13+)
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - UITextField wrapper avec barre “Terminer” (iOS 13+)
///
/// Ce composant encapsule un UITextField pour l’utiliser dans SwiftUI. Il
/// ajoute automatiquement une barre d’outils contenant un bouton “Terminer”
/// afin de permettre à l’utilisateur de fermer le clavier plus facilement.
/// Il gère également l’effacement du contenu sans fermer le clavier.
private struct AccessoryTextField: UIViewRepresentable {
    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: AccessoryTextField
        weak var textField: UITextField?

        init(_ parent: AccessoryTextField) { self.parent = parent }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text.wrappedValue = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if parent.returnKeyCloses {
                textField.resignFirstResponder()
                parent.onDone?()
                return false
            }
            return true
        }

        @objc func doneTapped(_ sender: UIBarButtonItem) {
            textField?.resignFirstResponder()
            parent.onDone?()
            UIApplication.shared.endEditing()
        }

        /// Intercepte l’appui sur la croix d’effacement pour empêcher la
        /// fermeture du clavier.
        func textFieldShouldClear(_ textField: UITextField) -> Bool {
            parent.text.wrappedValue = ""
            return false
        }
    }

    // Bindings & params
    var placeholder: String
    var text: Binding<String>

    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalizationType: UITextAutocapitalizationType = .none
    var isSecureTextEntry: Bool = false
    var returnKeyCloses: Bool = true
    var onDone: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.borderStyle = .none
        tf.placeholder = placeholder
        tf.text = text.wrappedValue
        tf.delegate = context.coordinator
        tf.keyboardType = keyboardType
        tf.autocapitalizationType = autocapitalizationType
        tf.isSecureTextEntry = isSecureTextEntry
        tf.clearButtonMode = .whileEditing
        tf.textContentType = textContentType

        // Toolbar “Terminer”
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(
            title: "Terminer",
            style: .done,
            target: context.coordinator,
            action: #selector(AccessoryTextField.Coordinator.doneTapped(_:))
        )
        toolbar.items = [flex, done]
        tf.inputAccessoryView = toolbar

        context.coordinator.textField = tf
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text.wrappedValue {
            uiView.text = text.wrappedValue
        }
        uiView.keyboardType = keyboardType
        uiView.autocapitalizationType = autocapitalizationType
        uiView.isSecureTextEntry = isSecureTextEntry
        uiView.textContentType = textContentType
        context.coordinator.textField = uiView
    }
}

// MARK: - ViewModel
///
/// La ViewModel porte toutes les données saisies dans cette étape de
/// l’onboarding. Elle gère la validation des champs, le chargement des
/// données dynamiques (liste des genres, des modes de découverte,
/// entreprises et évènements) et la communication avec le délégué qui
/// récupère les informations complétées.
final class OnboardingPhase1VM: ObservableObject {
    // Inputs
    @Published var firstname: String = ""
    @Published var lastname: String = ""
    @Published var birthday: Date? = nil

    // Valeur par défaut locale (pas de dépendance globale)
    @Published var selectedCountry: CountryCode = CountryCode(country: "France", code: "+33", flag: "🇫🇷")

    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var consent: Bool = false

    // Dynamic pickers (depuis API)
    @Published var gendersMap: [String: String] = [:]               // key -> label
    @Published var genderOptions: [String] = []                      // labels à afficher
    @Published var genderLabel: String = ""                          // label choisi

    @Published var discoverySourcesMap: [String: String] = [:]       // key -> label
    @Published var howWeMetOptions: [String] = []                    // labels à afficher
    @Published var howWeMetLabel: String = ""                       // label choisi (UI)

    @Published var enterprises: [SalesforceEnterprise] = []          // contient .id / .name
    @Published var selectedEnterpriseIndex: Int? = nil

    @Published var events: [SalesforceEvent] = []                    // contient .id / .name
    @Published var selectedEventIndex: Int? = nil

    // Pilotage du bouton "Suivant"
    @Published var canProceed: Bool = false

    weak var pageDelegate: OnboardingDelegate?

    // Birthday au format ISO (yyyy‑MM‑dd)
    private var birthdayISO: String? {
        guard let d = birthday else { return nil }
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: d)
    }

    private var cancellables = Set<AnyCancellable>()

    // Helpers ordre forcé (Femme → Homme → Non renseigné → reste)
    private func normalized(_ s: String) -> String {
        s.folding(options: .diacriticInsensitive, locale: .current)
         .trimmingCharacters(in: .whitespacesAndNewlines)
         .lowercased()
    }
    private func genderPriority(_ label: String) -> Int {
        let n = normalized(label)
        if n.contains("femme") { return 0 }
        if n.contains("homme") { return 1 }
        if n.contains("non renseigne") || n.contains("non renseigné") || n.contains("autre") || n.contains("non binaire") || n.contains("non-binaire") || n.contains("autres") { return 2 }
        return 3
    }

    init() {
        // Push + recompute à chaque changement utile
        var triggers: [AnyPublisher<Void, Never>] = []
        triggers.append($firstname.dropFirst().map { _ in () }.eraseToAnyPublisher())
        triggers.append($lastname.dropFirst().map { _ in () }.eraseToAnyPublisher())
        triggers.append($birthday.dropFirst().map { _ in () }.eraseToAnyPublisher())
        triggers.append($selectedCountry.dropFirst().map { _ in () }.eraseToAnyPublisher())
        triggers.append($phone.dropFirst().map { _ in () }.eraseToAnyPublisher())
        triggers.append($email.dropFirst().map { _ in () }.eraseToAnyPublisher())
        triggers.append($consent.dropFirst().map { _ in () }.eraseToAnyPublisher())
        triggers.append($genderLabel.dropFirst().map { _ in () }.eraseToAnyPublisher())
        triggers.append($howWeMetLabel.dropFirst().map { _ in () }.eraseToAnyPublisher())
        triggers.append($selectedEnterpriseIndex.dropFirst().map { _ in () }.eraseToAnyPublisher())
        triggers.append($selectedEventIndex.dropFirst().map { _ in () }.eraseToAnyPublisher())

        Publishers.MergeMany(triggers)
            .debounce(for: .milliseconds(60), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.pushToDelegate()
                self?.recomputeCanProceed()
            }
            .store(in: &cancellables)

        // Boot
        pushToDelegate()
        recomputeCanProceed()
    }

    // Affiche Entreprise/Événement si la réponse (LABEL affiché) contient "entreprise"
    var showCompanyAndEvent: Bool {
        let label = howWeMetLabel.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        return label.contains("entreprise")
    }

    // Exposé pour l'UI (validation locale)
    var isEnterpriseRequired: Bool { showCompanyAndEvent }
    var isEventRequired: Bool { showCompanyAndEvent }
    var isEnterpriseSelected: Bool { selectedEnterpriseIndex != nil }
    var isEventSelected: Bool { selectedEventIndex != nil }

    // MARK: - IDs & KEYS à transmettre
    private var discoverySourceKey: String? {
        discoverySourcesMap.first(where: { $0.value == howWeMetLabel })?.key
    }
    private var selectedEnterpriseId: String? {
        guard let i = selectedEnterpriseIndex,
              enterprises.indices.contains(i) else { return nil }
        return enterprises[i].id
    }
    private var selectedEventId: String? {
        guard let i = selectedEventIndex,
              events.indices.contains(i) else { return nil }
        return events[i].id
    }
    private var selectedEnterpriseName: String? {
        guard let i = selectedEnterpriseIndex, enterprises.indices.contains(i) else { return nil }
        return enterprises[i].name
    }
    private var selectedEventName: String? {
        guard let i = selectedEventIndex, events.indices.contains(i) else { return nil }
        return events[i].name
    }

    // MARK: - Validation
    var isFirstnameValid: Bool { firstname.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 }
    var isLastnameValid:   Bool { lastname.trimmingCharacters(in: .whitespacesAndNewlines).count  >= 2 }
    var isPhoneValid:      Bool { phone.filter(\.isNumber).count >= 9 }
    var isEmailValid:      Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return true } // email facultatif
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return trimmed.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    func recomputeCanProceed() {
        let baseOK = isFirstnameValid && isLastnameValid && isPhoneValid

        // Besoins spécifiques au cas "entreprise"
        let needsCompany = showCompanyAndEvent
        let hasCompany   = selectedEnterpriseIndex != nil
        let hasEvent     = selectedEventIndex != nil

        let next: Bool
        if needsCompany {
            // On exige les deux sélections
            next = baseOK && hasCompany && hasEvent
        } else {
            next = baseOK
        }

        if canProceed != next {
            canProceed = next
            NotificationCenter.default.post(
                name: .onboardingPhase1CanProceedChanged,
                object: nil,
                userInfo: ["enabled": next]
            )
        }
    }

    // MARK: - Networking (services existants)
    func loadMetadata() {
        PreOnboardingService.shared.loadMetadata { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let meta):
                    self.gendersMap = meta.user?.genders ?? [:]
                    self.discoverySourcesMap = meta.user?.discoverySources ?? [:]

                    // Genders: ordre forcé Femme > Homme > Non renseigné, puis le reste
                    let labelsG = Array(self.gendersMap.values)
                    if labelsG.isEmpty {
                        self.genderOptions = ["Femme", "Homme", "Non renseigné"]
                    } else {
                        self.genderOptions = labelsG.sorted { a, b in
                            let pa = self.genderPriority(a)
                            let pb = self.genderPriority(b)
                            if pa != pb { return pa < pb }
                            return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
                        }
                    }

                    // How we met : ordre demandé si disponible
                    let wanted = ["Bouche à oreille",
                                  "Internet",
                                  "Télévision / média",
                                  "Réseaux sociaux",
                                  "Sensibilisation entreprise"]
                    let labelsH = Array(self.discoverySourcesMap.values)
                    if labelsH.isEmpty {
                        self.howWeMetOptions = []
                    } else {
                        let setWanted = Set(wanted)
                        let first = wanted.filter { labelsH.contains($0) }
                        let rest  = labelsH.filter { !setWanted.contains($0) }
                            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
                        self.howWeMetOptions = first + rest
                    }

                case .failure:
                    self.gendersMap = [:]
                    self.discoverySourcesMap = [:]
                    self.genderOptions = ["Femme", "Homme", "Non renseigné"]
                    self.howWeMetOptions = []
                }
                self.recomputeCanProceed()
            }
        }
    }

    func loadEnterprises() {
        PreOnboardingService.shared.enterprisesDisplayList { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let list): self.enterprises = list
                case .failure:           self.enterprises = []
                }
                self.recomputeCanProceed()
            }
        }
    }

    func loadEventsForSelectedEnterprise() {
        guard let idx = selectedEnterpriseIndex,
              enterprises.indices.contains(idx),
              let enterpriseId = enterprises[idx].id else {
            events = []; selectedEventIndex = nil
            recomputeCanProceed()
            return
        }
        events = []; selectedEventIndex = nil
        PreOnboardingService.shared.eventsDisplayList(for: enterpriseId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list): self?.events = list
                case .failure:           self?.events = []
                }
                self?.recomputeCanProceed()
            }
        }
    }

    // MARK: - Delegate bridge
    func pushToDelegate() {
        let trimmedFirst = firstname.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLast  = lastname.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let digitsPhone  = phone.filter(\.isNumber)

        // IMPORTANT : on envoie les **clés/IDs**
        let howWeMetKey = discoverySourceKey
        let companyId   = showCompanyAndEvent ? selectedEnterpriseId : nil
        let eventId     = showCompanyAndEvent ? selectedEventId     : nil

        pageDelegate?.addUserInfos(
            firstname: isFirstnameValid ? trimmedFirst : nil,
            lastname:  isLastnameValid  ? trimmedLast  : nil,
            countryCode: selectedCountry,
            phone:     isPhoneValid ? digitsPhone : nil,
            email:     isEmailValid ? trimmedEmail : nil,
            consentEmail: consent,
            gender:    genderLabel.isEmpty ? nil : genderLabel, // mapping côté service si besoin
            howWeMet:  howWeMetKey,                              // ✅ clé (pas le label)
            birthdate: birthdayISO,                              // ✅ yyyy-MM-dd
            company:   companyId,                                // ✅ ID entreprise
            event:     eventId                                   // ✅ ID event
        )
    }
}

// MARK: - SwiftUI View
///
/// Cette vue est la première étape de l’onboarding. Elle recueille les
/// informations personnelles de l’utilisateur (nom, prénom, date de
/// naissance, genre), ses coordonnées de contact (téléphone, e-mail) et
/// comment il a connu Entourage. Le design a été harmonisé de manière à
/// respecter des marges latérales de 20 points et des espaces verticaux
/// entre sections de 20 points.
struct OnboardingPhase1View: View {
    @ObservedObject var vm: OnboardingPhase1VM

    private let countries: [CountryCode] = [
        CountryCode(country: "France",   code: "+33", flag: "🇫🇷"),
        CountryCode(country: "Belgique", code: "+32", flag: "🇧🇪"),
    ]

    @State private var showDateSheet = false
    @State private var tempDate = Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Titre principal pour la section « Informations personnelles »
                Text("Vos informations personnelles")
                    .font(.entourageTitle(20))
                    .padding(.leading, 0)
                    .padding(.top, 20)

                // Section identité
                IdentitySection(vm: vm,
                                showDateSheet: $showDateSheet,
                                tempDate: $tempDate)

                ContactSection(vm: vm, countries: countries)

                ProfileSection(vm: vm)

                Text("(*) champs obligatoires")
                    .font(.entourageBody(15))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 6)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        // Tap à côté → fermer le clavier (iOS 13+)
        .simultaneousGesture(TapGesture().onEnded { UIApplication.shared.endEditing() })
        .onAppear {
            vm.loadMetadata()
            vm.loadEnterprises()
            vm.pushToDelegate()
            vm.recomputeCanProceed()
        }
        .navigationBarTitle("Informations", displayMode: .inline)
        .sheet(isPresented: $showDateSheet) {
            DateSheet(tempDate: $tempDate) {
                vm.birthday = nil
                showDateSheet = false
            } onValidate: {
                vm.birthday = tempDate
                showDateSheet = false
            }
        }
    }
}

// MARK: - Sections
private struct IdentitySection: View {
    @ObservedObject var vm: OnboardingPhase1VM
    @Binding var showDateSheet: Bool
    @Binding var tempDate: Date

    @State private var showGenderAS = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SelectorRowButton(
                title: "Je suis",
                placeholder: "Sélectionner dans la liste",
                value: vm.genderLabel
            ) { showGenderAS = true }
            .actionSheet(isPresented: $showGenderAS) {
                var buttons: [ActionSheet.Button] = vm.genderOptions.map { opt in
                    .default(Text(opt)) { vm.genderLabel = opt }
                }
                buttons.append(.destructive(Text("Effacer")) { vm.genderLabel = "" })
                buttons.append(.cancel())
                return ActionSheet(title: Text("Je suis"), buttons: buttons)
            }

            FloatingField(title: "Prénom*", placeholder: "Ex. : Marie", text: $vm.firstname)

            FloatingField(title: "Nom*", placeholder: "Ex. : Dupont", text: $vm.lastname)

            DateRowButton(
                title: "Date d’anniversaire",
                placeholder: "Ex. : 22/10/1989",
                date: vm.birthday
            ) {
                tempDate = vm.birthday ?? Date()
                showDateSheet = true
            }
        }
    }
}

private struct ContactSection: View {
    @ObservedObject var vm: OnboardingPhase1VM
    let countries: [CountryCode]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Téléphone*")
                .font(.entourageTitle(15))

            HStack(spacing: 12) {
                // ---- Boîte drapeau (52) ----
                ZStack(alignment: .leading) {
                    HStack {
                        Text(vm.selectedCountry.flag)
                            .font(.system(size: 28))
                            .frame(width: 44, height: 52, alignment: .center)
                            .padding(.leading, 10)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.entourageBody(15))
                            .foregroundColor(Color(UIColor.appOrange))
                            .padding(.trailing, 10)
                    }
                    .contentShape(Rectangle())
                    .allowsHitTesting(false)

                    Picker("", selection: Binding<String>(
                        get: { vm.selectedCountry.code },
                        set: { newCode in
                            if let found = countries.first(where: { $0.code == newCode }) {
                                vm.selectedCountry = found
                            }
                        })) {
                            ForEach(countries, id: \.code) { c in
                                Text(c.flag).tag(c.code)
                            }
                        }
                        .labelsHidden()
                        .opacity(0.02) // capte le tap mais invisible
                }
                .frame(height: 52)
                .frame(width: 100, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.25))
                )

                // ---- Boîte numéro (52) — même style EXACT ----
                BoxedTextField(placeholder: "06 XX XX XX XX", text: $vm.phone)
            }

            FloatingField(title: "E-mail",
                          placeholder: "Ex. : marie.dupont@email.com",
                          text: $vm.email,
                          keyboard: .emailAddress,
                          contentType: .emailAddress)
        }
    }
}

private struct ProfileSection: View {
    @ObservedObject var vm: OnboardingPhase1VM

    @State private var showHowAS = false
    @State private var showEnterpriseAS = false
    @State private var showEventAS = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            SelectorRowButton(
                title: "Comment nous avez-vous connu ?",
                placeholder: "Sélectionner dans la liste",
                value: vm.howWeMetLabel
            ) { showHowAS = true }
            .actionSheet(isPresented: $showHowAS) {
                var buttons: [ActionSheet.Button] = vm.howWeMetOptions.map { opt in
                    .default(Text(opt)) { vm.howWeMetLabel = opt }
                }
                buttons.append(.destructive(Text("Effacer")) { vm.howWeMetLabel = "" })
                buttons.append(.cancel())
                return ActionSheet(title: Text("Comment nous avez-vous connu ?"), buttons: buttons)
            }

            if #available(iOS 15.0, *) {
                Toggle(isOn: $vm.consent) {
                    Text("Je souhaite recevoir des informations et des conseils de l’équipe Entourage")
                        .font(.entourageBody(11))
                }
                .tint(Color(UIColor.appOrange))
            } else {
                Toggle(isOn: $vm.consent) {
                    Text("Je souhaite recevoir des informations et des conseils de l’équipe Entourage")
                        .font(.entourageBody(11))
                }
                .accentColor(Color(UIColor.appOrange))
            }

            if vm.showCompanyAndEvent {
                Divider().padding(.vertical, 4)

                // Entreprise (affichage = nom, envoi = ID)
                SelectorRowButton(
                    title: "Nom de votre entreprise",
                    placeholder: vm.enterprises.isEmpty ? "Chargement..." : "Sélectionner dans la liste",
                    value: (vm.selectedEnterpriseIndex.flatMap { idx in
                        vm.enterprises.indices.contains(idx) ? (vm.enterprises[idx].name ?? "") : ""
                    }) ?? "",
                    isRequired: vm.isEnterpriseRequired,
                    showError: vm.isEnterpriseRequired && !vm.isEnterpriseSelected,
                    errorText: "Champ requis"
                ) { showEnterpriseAS = true }
                .actionSheet(isPresented: $showEnterpriseAS) {
                    var buttons: [ActionSheet.Button] =
                        vm.enterprises.enumerated().map { i, ent in
                            .default(Text(ent.name ?? "")) {
                                vm.selectedEnterpriseIndex = i
                                vm.loadEventsForSelectedEnterprise()
                            }
                        }
                    buttons.append(.destructive(Text("Effacer")) {
                        vm.selectedEnterpriseIndex = nil
                        vm.events = []
                        vm.selectedEventIndex = nil
                    })
                    buttons.append(.cancel())
                    return ActionSheet(title: Text("Nom de votre entreprise"), buttons: buttons)
                }

                // Événement (affichage = nom, envoi = ID)
                SelectorRowButton(
                    title: "Événement auquel vous participez",
                    placeholder: vm.events.isEmpty ? "Sélectionner une entreprise d’abord" : "Sélectionner dans la liste",
                    value: (vm.selectedEventIndex.flatMap { idx in
                        vm.events.indices.contains(idx) ? (vm.events[idx].name ?? "") : ""
                    }) ?? "",
                    isRequired: vm.isEventRequired,
                    showError: vm.isEventRequired && !vm.isEventSelected,
                    errorText: "Champ requis"
                ) { showEventAS = true }
                .actionSheet(isPresented: $showEventAS) {
                    var buttons: [ActionSheet.Button] =
                        vm.events.enumerated().map { i, ev in
                            .default(Text(ev.name ?? "")) { vm.selectedEventIndex = i }
                        }
                    buttons.append(.destructive(Text("Effacer")) { vm.selectedEventIndex = nil })
                    buttons.append(.cancel())
                    return ActionSheet(title: Text("Événement auquel vous participez"), buttons: buttons)
                }
            }
        }
    }
}

// MARK: - Components
private struct FloatingField: View {
    var title: String
    var placeholder: String
    @Binding var text: String

    // Params clavier
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    var autocap: UITextAutocapitalizationType = .none
    var secure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.entourageTitle(15))

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.25))

                AccessoryTextField(
                    placeholder: placeholder,
                    text: $text,
                    keyboardType: keyboard,
                    textContentType: contentType,
                    autocapitalizationType: autocap,
                    isSecureTextEntry: secure,
                    returnKeyCloses: true,
                    onDone: { UIApplication.shared.endEditing() }
                )
                .padding(.horizontal, 12)
                .frame(height: 44)
            }
        }
    }
}

/// Champ encadré de **hauteur fixe 52** pour matcher la boîte du drapeau
private struct BoxedTextField: View {
    var placeholder: String
    @Binding var text: String

    private let height: CGFloat = 52
    private let corner: CGFloat = 12

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: corner)
                .stroke(Color.secondary.opacity(0.25))

            AccessoryTextField(
                placeholder: placeholder,
                text: $text,
                keyboardType: .numberPad,
                textContentType: .telephoneNumber,
                autocapitalizationType: .none,
                isSecureTextEntry: false,
                returnKeyCloses: true,
                onDone: { UIApplication.shared.endEditing() }
            )
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(height: height)
    }
}

private struct SelectorRowButton: View {
    var title: String
    var placeholder: String
    var value: String
    var isRequired: Bool = false
    var showError: Bool = false
    var errorText: String? = nil
    var onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(title).font(.entourageTitle(15))
                if isRequired {
                    Text("*").font(.entourageTitle(15)).foregroundColor(.red)
                }
            }

            Button(action: onTap) {
                HStack {
                    Text(value.isEmpty ? placeholder : value)
                        .font(.entourageBody(15))
                        .lineLimit(1)
                        .foregroundColor(value.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.entourageBody(15))
                        .foregroundColor(Color(UIColor.appOrange))
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(showError ? Color.red.opacity(0.7) : Color.secondary.opacity(0.25))
                )
            }

            if showError, let errorText {
                Text(errorText)
                    .font(.entourageBody(12))
                    .foregroundColor(.red)
            }
        }
    }
}

private struct DateRowButton: View {
    var title: String
    var placeholder: String
    var date: Date?
    var onTap: () -> Void

    private var formatted: String {
        guard let d = date else { return "" }
        let df = DateFormatter(); df.dateStyle = .medium
        return df.string(from: d)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.entourageTitle(15))
            Button(action: onTap) {
                HStack {
                    Text(formatted.isEmpty ? placeholder : formatted)
                        .font(.entourageBody(15))
                        .foregroundColor(formatted.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "calendar")
                        .font(.entourageBody(15))
                        .foregroundColor(Color(UIColor.appOrange))
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.25))
                )
            }
        }
    }
}

// MARK: - UIKit bridge (une seule VM partagée)
final class OnboardingPhase1ViewController: UIHostingController<OnboardingPhase1View> {

    // Une seule instance, partagée entre le VC et la View SwiftUI
    let vm: OnboardingPhase1VM

    // Déférencement vers l'extérieur (propagé vers la VM)
    weak var pageDelegateBridge: OnboardingDelegate? {
        didSet { vm.pageDelegate = pageDelegateBridge }
    }

    // Compat API externe
    var userFirstname: String? { didSet { vm.firstname = userFirstname ?? "" } }
    var userLastname:  String? { didSet { vm.lastname  = userLastname  ?? "" } }
    var countryCode:   CountryCode = CountryCode(country: "France", code: "+33", flag: "🇫🇷") { didSet { vm.selectedCountry = countryCode } }
    var phone:         String? { didSet { vm.phone = phone ?? "" } }
    var email:         String? { didSet { vm.email = email ?? "" } }
    var hasConsent:    Bool = false { didSet { vm.consent = hasConsent } }

    // Nouveaux champs
    var gender:   String? { didSet { vm.genderLabel = gender ?? "" } }
    var howWeMet: String? { didSet { vm.howWeMetLabel = howWeMet ?? "" } } // UI label only; clé est dérivée dans la VM
    var company:  String?
    var eventName: String?

    // Init programmatique
    init() {
        let sharedVM = OnboardingPhase1VM()
        self.vm = sharedVM
        super.init(rootView: OnboardingPhase1View(vm: sharedVM))
        view.isOpaque = false
        view.backgroundColor = .clear
    }

    // Init via storyboard
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        let sharedVM = OnboardingPhase1VM()
        self.vm = sharedVM
        super.init(coder: aDecoder, rootView: OnboardingPhase1View(vm: sharedVM))
        view.isOpaque = false
        view.backgroundColor = .clear
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Informations"
    }

    // Compat avec l’ancien nom
    var pageDelegate: OnboardingDelegate? {
        get { pageDelegateBridge }
        set { pageDelegateBridge = newValue }
    }
}

// MARK: - Sheet Date (compatible iOS 13+)
private struct DateSheet: View {
    @Binding var tempDate: Date
    var onClear: () -> Void
    var onValidate: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Sélectionner une date")
                .font(.entourageTitle(15))
                .padding(.top, 12)

            Group {
                if #available(iOS 14.0, *) {
                    DatePicker("",
                               selection: $tempDate,
                               in: ...Date(),
                               displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                } else {
                    DatePicker("",
                               selection: $tempDate,
                               in: ...Date(),
                               displayedComponents: .date)
                        .labelsHidden()
                }
            }
            .frame(maxWidth: .infinity)

            HStack {
                Button("Effacer", action: onClear)
                Spacer()
                Button("Valider", action: onValidate)
                    .font(.entourageTitle(15))
            }
            .padding()
        }
    }
}
