import SwiftUI
import Combine
import CoreLocation
import GooglePlaces


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
    @Published var gendersMap: [String: String] = [:]
    @Published var genderOptions: [String] = []
    @Published var genderLabel: String = ""

    @Published var discoverySourcesMap: [String: String] = [:]
    @Published var howWeMetOptions: [String] = []
    @Published var howWeMetLabel: String = ""

    @Published var enterprises: [SalesforceEnterprise] = []
    @Published var selectedEnterpriseIndex: Int? = nil

    @Published var events: [SalesforceEvent] = []
    @Published var selectedEventIndex: Int? = nil

    weak var pageDelegate: OnboardingDelegate?

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Push délégué à chaque changement utile
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
            .sink { [weak self] _ in self?.pushToDelegate() }
            .store(in: &cancellables)

        // Premier push pour que "Suivant" ait toujours un état
        pushToDelegate()
    }

    // Affiche Entreprise/Événement si la réponse contient "entreprise"
    var showCompanyAndEvent: Bool {
        let label = howWeMetLabel.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        return label.contains("entreprise")
    }

    var selectedEnterpriseName: String? {
        guard let i = selectedEnterpriseIndex, enterprises.indices.contains(i) else { return nil }
        return enterprises[i].name
    }

    var selectedEventName: String? {
        guard let i = selectedEventIndex, events.indices.contains(i) else { return nil }
        return events[i].name
    }

    // MARK: - Validation

    var isFirstnameValid: Bool { firstname.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 }
    var isLastnameValid:   Bool { lastname.trimmingCharacters(in: .whitespacesAndNewlines).count  >= 2 }
    var isPhoneValid:      Bool { phone.filter(\.isNumber).count >= 9 }
    var isEmailValid:      Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return true }
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return trimmed.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
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
            }
        }
    }

    func loadEventsForSelectedEnterprise() {
        guard let idx = selectedEnterpriseIndex,
              enterprises.indices.contains(idx),
              let enterpriseId = enterprises[idx].id else {
            events = []; selectedEventIndex = nil
            return
        }
        events = []; selectedEventIndex = nil
        PreOnboardingService.shared.eventsDisplayList(for: enterpriseId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list): self?.events = list
                case .failure:           self?.events = []
                }
            }
        }
    }

    // MARK: - Delegate bridge

    func pushToDelegate() {
        let trimmedFirst = firstname.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLast  = lastname.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let digitsPhone  = phone.filter(\.isNumber)

        pageDelegate?.addUserInfos(
            firstname: isFirstnameValid ? trimmedFirst : nil,
            lastname:  isLastnameValid  ? trimmedLast  : nil,
            countryCode: selectedCountry,
            phone:     isPhoneValid ? digitsPhone : nil,
            email:     isEmailValid ? trimmedEmail : nil,
            consentEmail: consent,
            gender:    genderLabel.isEmpty ? nil : genderLabel,
            howWeMet:  howWeMetLabel.isEmpty ? nil : howWeMetLabel,
            company:   showCompanyAndEvent ? (selectedEnterpriseName ?? "") : nil,
            event:     showCompanyAndEvent ? (selectedEventName ?? "") : nil
        )
    }
}

// MARK: - SwiftUI View

struct OnboardingPhase1View: View {
    @ObservedObject var vm: OnboardingPhase1VM

    private let countries: [CountryCode] = [
        CountryCode(country: "France",   code: "+33", flag: "🇫🇷"),
        CountryCode(country: "Belgique", code: "+32", flag: "🇧🇪"),
        CountryCode(country: "Suisse",   code: "+41", flag: "🇨🇭"),
        CountryCode(country: "Canada",   code: "+1",  flag: "🇨🇦")
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
        .background(Color.white) // tout blanc
        .onAppear {
            vm.loadMetadata()
            vm.loadEnterprises()
            vm.pushToDelegate() // push initial garanti
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
            Text("Identité").font(.entourageTitle(15))

            // Je suis
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
            HelperErrorRow(isValid: vm.isFirstnameValid, message: "2 caractères minimum")

            FloatingField(title: "Nom*", placeholder: "Ex. : Dupont", text: $vm.lastname)
            HelperErrorRow(isValid: vm.isLastnameValid, message: "2 caractères minimum")

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
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact").font(.entourageTitle(15))

            HStack(spacing: 12) {
                // Picker roue masqué avec label custom
                ZStack(alignment: .leading) {
                    HStack {
                        Text("\(vm.selectedCountry.flag) \(vm.selectedCountry.country) \(vm.selectedCountry.code)")
                            .font(.entourageBody(15))
                            .padding(.leading, 12)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.entourageBody(15))
                            .padding(.trailing, 12)
                    }
                    .allowsHitTesting(false)

                    Picker("", selection: Binding<String>(
                        get: { vm.selectedCountry.code },
                        set: { newCode in
                            if let found = countries.first(where: { $0.code == newCode }) {
                                vm.selectedCountry = found
                            }
                        })) {
                            ForEach(countries, id: \.code) { c in
                                Text("\(c.flag) \(c.country) \(c.code)")
                                    .font(.entourageBody(15))
                                    .tag(c.code)
                            }
                        }
                        .labelsHidden()
                        .opacity(0.02)
                }
                .frame(height: 44)
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.25)))
                .frame(maxWidth: 220)

                FloatingField(title: "Téléphone*", placeholder: "06 XX XX XX XX", text: $vm.phone)
                    .keyboardType(.numberPad)
                    .textContentType(.telephoneNumber)
            }

            HelperErrorRow(isValid: vm.isPhoneValid, message: "Au moins 9 chiffres")

            FloatingField(title: "E-mail", placeholder: "Ex. : marie.dupont@email.com", text: $vm.email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            HelperErrorRow(isValid: vm.isEmailValid, message: "E-mail invalide")
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
            Text("Profil & Découverte").font(.entourageTitle(15))

            // Comment vous nous avez connus ?
            SelectorRowButton(
                title: "Comment vous nous avez connus ?",
                placeholder: "Sélectionner dans la liste",
                value: vm.howWeMetLabel
            ) { showHowAS = true }
            .actionSheet(isPresented: $showHowAS) {
                var buttons: [ActionSheet.Button] = vm.howWeMetOptions.map { opt in
                    .default(Text(opt)) { vm.howWeMetLabel = opt }
                }
                buttons.append(.destructive(Text("Effacer")) { vm.howWeMetLabel = "" })
                buttons.append(.cancel())
                return ActionSheet(title: Text("Comment vous nous avez connus ?"), buttons: buttons)
            }

            if #available(iOS 15.0, *) {
                Toggle(isOn: $vm.consent) {
                    Text("Je souhaite recevoir des informations et des conseils de l’équipe Entourage")
                        .font(.entourageBody(11)) // opt-in en body 11
                }
                .tint(.orange)
            } else {
                // Fallback on earlier versions
            }

            if vm.showCompanyAndEvent {
                Divider().padding(.vertical, 4)

                // Entreprise
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

                // Événement
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

// MARK: - Sheet Date (iOS 13 OK)

private struct DateSheet: View {
    @Binding var tempDate: Date
    var onClear: () -> Void
    var onValidate: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            Text("Sélectionner une date")
                .font(.entourageTitle(15))
                .padding(.top, 12)
            DatePicker("", selection: $tempDate, in: ...Date(), displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(WheelDatePickerStyle())
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

private struct HelperErrorRow: View {
    var isValid: Bool
    var message: String
    var body: some View {
        Group {
            if !isValid {
                Text(message)
                    .font(.entourageBody(13))
                    .foregroundColor(.red)
                    .padding(.leading, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - UIKit bridge

final class OnboardingPhase1ViewController: UIHostingController<OnboardingPhase1View> {
    private let vm = OnboardingPhase1VM()

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
    var howWeMet: String? { didSet { vm.howWeMetLabel = howWeMet ?? "" } }
    var company:  String?
    var eventName: String?

    init() {
        let vm = OnboardingPhase1VM()
        let view = OnboardingPhase1View(vm: vm)
        super.init(rootView: view)
        self.vm.pageDelegate = nil
        self.view.backgroundColor = .white
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        let vm = OnboardingPhase1VM()
        super.init(coder: aDecoder, rootView: OnboardingPhase1View(vm: vm))
        self.vm.pageDelegate = nil
        self.view.backgroundColor = .white
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
