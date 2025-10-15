import SwiftUI
import Combine
import CoreLocation
import GooglePlaces

// MARK: - Notification (écoutée par le StartController si besoin)
extension Notification.Name {
    static let onboardingPhase1CanProceedChanged = Notification.Name("onboardingPhase1CanProceedChanged")
}

// MARK: - Fonts SwiftUI (Quicksand-Bold & NunitoSans-Regular)
private extension Font {
    static func entourageTitle(_ size: CGFloat = 15) -> Font {
        .custom("Quicksand-Bold", size: size)
    }
    static func entourageBody(_ size: CGFloat = 15) -> Font {
        .custom("NunitoSans-Regular", size: size)
    }
}

// MARK: - ViewModel
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
    @Published var howWeMetLabel: String = ""                        // label choisi (UI)

    @Published var enterprises: [SalesforceEnterprise] = []          // contient .id / .name
    @Published var selectedEnterpriseIndex: Int? = nil

    @Published var events: [SalesforceEvent] = []                    // contient .id / .name
    @Published var selectedEventIndex: Int? = nil

    // Pilotage du bouton "Suivant"
    @Published var canProceed: Bool = false

    weak var pageDelegate: OnboardingDelegate?

    // Birthday au format ISO (yyyy-MM-dd)
    private var birthdayISO: String? {
        guard let d = birthday else { return nil }
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: d)
    }

    private var cancellables = Set<AnyCancellable>()

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

    // MARK: - IDs & KEYS à transmettre
    /// Clé de discovery source (à partir du label choisi)
    private var discoverySourceKey: String? {
        discoverySourcesMap.first(where: { $0.value == howWeMetLabel })?.key
    }
    /// ID Entreprise sélectionnée (string attendu par l’API)
    private var selectedEnterpriseId: String? {
        guard let i = selectedEnterpriseIndex,
              enterprises.indices.contains(i) else { return nil }
        return enterprises[i].id
    }
    /// ID Événement sélectionné (string attendu par l’API)
    private var selectedEventId: String? {
        guard let i = selectedEventIndex,
              events.indices.contains(i) else { return nil }
        return events[i].id
    }
    /// Nom Entreprise (pour l’affichage uniquement)
    private var selectedEnterpriseName: String? {
        guard let i = selectedEnterpriseIndex, enterprises.indices.contains(i) else { return nil }
        return enterprises[i].name
    }
    /// Nom Événement (pour l’affichage uniquement)
    private var selectedEventName: String? {
        guard let i = selectedEventIndex, events.indices.contains(i) else { return nil }
        return events[i].name
    }

    // MARK: - Validation
    var isFirstnameValid: Bool { firstname.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 }
    var isLastnameValid:   Bool { lastname.trimmingCharacters(in: .whitespacesAndNewlines).count  >= 2 }
    var isPhoneValid:      Bool { phone.filter(\.isNumber).count >= 9 } // 9 mini (international)
    var isEmailValid:      Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return true } // email facultatif
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return trimmed.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    // MARK: - Proceed logic
    func recomputeCanProceed() {
        let baseOK = isFirstnameValid && isLastnameValid && isPhoneValid
        let companyOK: Bool
        if showCompanyAndEvent {
            companyOK = (selectedEnterpriseIndex != nil) && (selectedEventIndex != nil)
        } else {
            companyOK = true
        }
        let next = baseOK && companyOK
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

                    // Genders: fallback si API vide
                    let labelsG = Array(self.gendersMap.values)
                    self.genderOptions = labelsG.isEmpty
                        ? ["Homme", "Femme", "Non binaire"]
                        : labelsG.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }

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
                    self.genderOptions = ["Homme", "Femme", "Non binaire"]
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
            VStack(alignment: .leading, spacing: 16) {
                CardContainer {
                    IdentitySection(vm: vm,
                                    showDateSheet: $showDateSheet,
                                    tempDate: $tempDate)

                    Divider().padding(.vertical, 4)

                    ContactSection(vm: vm, countries: countries)

                    Divider().padding(.vertical, 4)

                    ProfileSection(vm: vm)
                }

                Text("(*) champs obligatoires")
                    .font(.entourageBody(15))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 6)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(Color.white)
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
        VStack(alignment: .leading, spacing: 16) {
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
        VStack(alignment: .leading, spacing: 12) {
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
                        .opacity(0.02)
                }
                .frame(height: 52)
                .frame(width: 100, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.25))
                )

                // ---- Boîte numéro (52) — même style EXACT ----
                BoxedTextField(placeholder: "06 XX XX XX XX", text: $vm.phone)
                    .keyboardType(.numberPad)
                    .textContentType(.telephoneNumber)
            }

            FloatingField(title: "E-mail", placeholder: "Ex. : marie.dupont@email.com", text: $vm.email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
        }
    }
}

private struct ProfileSection: View {
    @ObservedObject var vm: OnboardingPhase1VM

    @State private var showHowAS = false
    @State private var showEnterpriseAS = false
    @State private var showEventAS = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            SelectorRowButton(
                title: "Comment nous avez-vous connus ?",
                placeholder: "Sélectionner dans la liste",
                value: vm.howWeMetLabel
            ) { showHowAS = true }
            .actionSheet(isPresented: $showHowAS) {
                var buttons: [ActionSheet.Button] = vm.howWeMetOptions.map { opt in
                    .default(Text(opt)) { vm.howWeMetLabel = opt }
                }
                buttons.append(.destructive(Text("Effacer")) { vm.howWeMetLabel = "" })
                buttons.append(.cancel())
                return ActionSheet(title: Text("Comment nous avez-vous connus ?"), buttons: buttons)
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
                    }) ?? ""
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
                    }) ?? ""
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

// MARK: - Card container (blanc)
private struct CardContainer<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 20) { content }
            .padding(16)
            .background(Color.white)
            .cornerRadius(20)
    }
}

// MARK: - Components
private struct FloatingField: View {
    var title: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.entourageTitle(15))
            TextField(placeholder, text: $text)
                .font(.entourageBody(15))
                .autocapitalization(.none)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.25))
                )
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
            TextField(placeholder, text: $text)
                .font(.entourageBody(15))
                .autocapitalization(.none)
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
    var onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.entourageTitle(15))
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
                        .stroke(Color.secondary.opacity(0.25))
                )
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
