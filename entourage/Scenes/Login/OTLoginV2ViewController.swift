import SwiftUI
import Combine
import UIKit
import SVProgressHUD
import SimpleKeychain

// MARK: - Extensions & Helpers (Style & Utils)

private extension Font {
    static func entourageTitle(_ size: CGFloat = 20) -> Font {
        .custom("Quicksand-Bold", size: size)
    }
    static func entourageBody(_ size: CGFloat = 15) -> Font {
        .custom("NunitoSans-Regular", size: size)
    }
}



// MARK: - Components

/// Wrapper UITextField pour SwiftUI avec Toolbar "Terminer"
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
    }

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
        tf.textContentType = textContentType
        
        // Toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Terminer", style: .done, target: context.coordinator, action: #selector(Coordinator.doneTapped(_:)))
        toolbar.items = [flex, done]
        tf.inputAccessoryView = toolbar

        context.coordinator.textField = tf
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text.wrappedValue {
            uiView.text = text.wrappedValue
        }
        // Mise à jour dynamique pour le toggle mot de passe
        if uiView.isSecureTextEntry != isSecureTextEntry {
            uiView.isSecureTextEntry = isSecureTextEntry
        }
    }
}

/// Champ de saisie simple (flottant)
private struct FloatingField: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.entourageTitle(15))
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.25))
                AccessoryTextField(placeholder: placeholder, text: $text, keyboardType: keyboard, onDone: { UIApplication.shared.endEditing() })
                    .padding(.horizontal, 12)
                    .frame(height: 52)
            }
        }
    }
}

/// Champ spécifique pour le mot de passe (Code) avec l'œil
private struct PasswordFloatingField: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    @Binding var isSecured: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.entourageTitle(15))
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    // Bordure orange si actif (simulé ici par non vide) ou gris sinon, pour matcher l'image
                    .stroke(text.isEmpty ? Color.secondary.opacity(0.25) : Color(UIColor.appOrange).opacity(0.8))
                
                HStack {
                    AccessoryTextField(
                        placeholder: placeholder,
                        text: $text,
                        keyboardType: .numberPad, // Code à 6 chiffres
                        isSecureTextEntry: isSecured,
                        onDone: { UIApplication.shared.endEditing() }
                    )
                    
                    Button(action: {
                        isSecured.toggle()
                    }) {
                        Image(systemName: isSecured ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
                }
                .padding(.horizontal, 12)
                .frame(height: 52)
            }
        }
    }
}

/// Champ encadré de hauteur fixe 52 (pour le téléphone)
private struct BoxedTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.25))
            AccessoryTextField(
                placeholder: placeholder,
                text: $text,
                keyboardType: .numberPad,
                textContentType: .telephoneNumber,
                onDone: { UIApplication.shared.endEditing() }
            )
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(height: 52)
    }
}

// MARK: - ViewModel

final class LoginViewModel: ObservableObject {
    // Inputs
    @Published var phone: String = ""
    @Published var password: String = "" // Le Code
    @Published var selectedCountry: CountryCode
    @Published var isPasswordSecured: Bool = true
    
    // UI Logic
    @Published var showCountrySheet: Bool = false // Gère l'ActionSheet du pays
    
    // Network Logic State
    @Published var isLoading: Bool = false
    @Published var timeOut: Int = 0
    private let timeOutLength = 60
    private var timer: Timer? = nil
    
    // Alerts
    @Published var alertMessage: String? = nil
    @Published var showAlert: Bool = false
    @Published var showResendConfirmation: Bool = false
    
    // Constants
    let countries: [CountryCode] = [
        CountryCode(country: "France", code: "+33", flag: "🇫🇷"),
        CountryCode(country: "Belgique", code: "+32", flag: "🇧🇪")
    ]
    private let minimumCharacters = 9
    
    // External delegates (Navigation callbacks)
    var onSuccess: (() -> Void)?
    var onBack: (() -> Void)?
    var onChangePhone: (() -> Void)?

    init() {
        // Default Country logic
        self.selectedCountry = countries.first ?? CountryCode(country: "France", code: "+33", flag: "🇫🇷")
    }
    
    // MARK: - Keychain Logic
    func checkForKeychain() {
        if let phoneK = A0SimpleKeychain().string(forKey: kKeychainPhone),
           let pwdK = A0SimpleKeychain().string(forKey: kKeychainPassword) {
            self.phone = phoneK
            self.password = pwdK
        }
    }
    
    // MARK: - Validation & Login
    
    func validateAndLogin() {
        // Validation length Phone
        if phone.count < minimumCharacters {
            triggerAlert(message: String(format: "error_login_phone_length".localized, minimumCharacters))
            return
        }
        
        // Validation length Code
        if password.count != 6 {
            triggerAlert(message: "error_login_code_lenght".localized)
            return
        }
        
        // Format Phone
        let formattedPhone = Utils.validatePhoneFormat(countryCode: selectedCountry.code, phone: phone)
        
        if !isLoading {
            isLoading = true
            stopTimer()
            performLogin(phone: formattedPhone, code: password)
        }
    }
    
    private func performLogin(phone: String, code: String) {
        SVProgressHUD.show()
        
        AuthService.postLogin(phone: phone, password: code) { [weak self] (user, error, isFirstLogin) in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading = false
                self.handleLoginError(error)
            } else {
                Logger.print("login return user ok : \(String(describing: user))")
                if user == nil {
                    self.handleLoginError(EntourageNetworkError()) // Fallback
                    return
                }
                
                var newUser = user
                self.isLoading = false
                newUser?.phone = phone
                UserDefaults.currentUser = newUser
                UserDefaults.temporaryUser = nil
                
                // Success Navigation
                self.onSuccess?()
            }
        }
    }
    
    private func handleLoginError(_ error: EntourageNetworkError) {
        var alertText = "connection_error".localized
        
        if error.code.contains("UNAUTHORIZED") {
            alertText = "error_login_phoneNumberOrCode".localized
        } else if error.code.contains("INVALID_PHONE_FORMAT") {
            alertText = "error_login_phoneNumberFormat".localized
        } else if let errorCode = error.error as NSError?, errorCode.code == NSURLErrorNotConnectedToInternet {
            alertText = errorCode.localizedDescription
        }
        
        triggerAlert(message: alertText)
    }
    
    // MARK: - Resend Code Logic
    
    func tapResendCode() {
        if phone.count < minimumCharacters {
            triggerAlert(message: String(format: "error_login_phone_length".localized, minimumCharacters))
            return
        }
        
        if timeOut > 0 && timeOut != timeOutLength {
            triggerAlert(message: String(format: "onboard_sms_pop_alert".localized, timeOut))
        } else {
            // Demande de confirmation avant envoi
            showResendConfirmation = true
        }
    }
    
    func confirmResendCode() {
        var rawPhone = phone.trimmingCharacters(in: .whitespaces)
        // Petit fix local pour le formatage manuel si besoin
        if !rawPhone.hasPrefix("+") && rawPhone.hasPrefix("0") {
            rawPhone.remove(at: .init(encodedOffset: 0))
        }
        let fullPhone = "\(selectedCountry.code)\(rawPhone)"
        
        SVProgressHUD.show()
        AuthService.regenerateSecretCode(phone: fullPhone) { [weak self] error in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            
            if let error = error {
                var msg = "requestNotSent".localized
                if error.code.contains("USER_NOT_FOUND") {
                    msg = "error_login_resendCode_unknow".localized
                }
                self.triggerAlert(message: msg)
            } else {
                SVProgressHUD.show(withStatus: "requestSent".localized)
                SVProgressHUD.dismiss(withDelay: 1.5)
                self.startTimer()
            }
        }
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        stopTimer()
        timeOut = timeOutLength
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeOut -= 1
            if self.timeOut <= 0 {
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timeOut = 0
    }
    
    private func triggerAlert(message: String) {
        self.alertMessage = message
        self.showAlert = true
    }
}

// MARK: - SwiftUI View

struct LoginView: View {
    @ObservedObject var vm: LoginViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            // --------------------------------------------------------
            // 1. Header Align (Titre + Back)
            // --------------------------------------------------------
            HStack(spacing: 16) {
                Button(action: { vm.onBack?() }) {
                    Image("back_arrow") // ou "back_arrow" / "back_button_white"
                        .renderingMode(.template)
                        .foregroundColor(.black)
                        .padding(.vertical, 12)
                }
                
                Text("login_title".localized) // "Connexion"
                    .font(.entourageTitle(24))
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 20)
            
            // --------------------------------------------------------
            // 2. ScrollView (Inputs + Bloc Resend Code)
            // --------------------------------------------------------
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // --- A. Section Téléphone ---
                    VStack(alignment: .leading, spacing: 6) {
                        // Titre du champ téléphne (optionnel, selon le design exact, l'image montre un label flottant ou placeholder)
                        // L'image montre "Téléphone*" en label au dessus ou dans le cadre.
                        // On garde le style "FloatingField" actuel qui met le titre au dessus.
                        Text("login_label_phone".localized)
                            .font(.entourageTitle(15))
                        
                        HStack(spacing: 12) {
                            // Sélecteur Pays
                            Button(action: {
                                vm.showCountrySheet = true
                            }) {
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
                                }
                                .frame(height: 52)
                                .frame(width: 100)
                                .background(
                                    RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.25))
                                )
                            }
                            .actionSheet(isPresented: $vm.showCountrySheet) {
                                ActionSheet(
                                    title: Text("Sélectionnez un pays"),
                                    buttons: vm.countries.map { country in
                                        .default(Text("\(country.flag) \(country.country)")) {
                                            vm.selectedCountry = country
                                        }
                                    } + [.cancel(Text("Annuler"))]
                                )
                            }
                            
                            // Champ numéro
                            BoxedTextField(placeholder: "login_phone_placeholder".localized, text: $vm.phone)
                        }
                    }
                    
                    // --- B. Section Code ---
                    VStack(alignment: .leading, spacing: 6) {
                        PasswordFloatingField(
                            title: "login_label_code".localized, // "Saisir votre code"
                            placeholder: "Ex : 123456",
                            text: $vm.password,
                            isSecured: $vm.isPasswordSecured
                        )
                    }
                    
                    // --- C. Bloc "Code Oublié" (Encadré) ---
                    // C'est ici que ça change par rapport au code précédent
                    VStack(spacing: 8) {
                        Text("login_forgot_code_title".localized) // "Vous avez oublié votre code ?"
                            .font(.entourageBody(15))
                            .foregroundColor(.black)
                        
                        Button(action: {
                            vm.tapResendCode()
                        }) {
                            Text("login_button_resend_code".localized) // "Recevoir un nouveau code par sms"
                                .font(.entourageTitle(15)) // Style gras/orange
                                .foregroundColor(Color(UIColor.appOrange))
                                .underline()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.25))
                    )
                    .padding(.top, 10)
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .simultaneousGesture(TapGesture().onEnded { UIApplication.shared.endEditing() })
            
            // --------------------------------------------------------
            // 3. Footer (Changement numéro + Gros Bouton Connect)
            // --------------------------------------------------------
            VStack(spacing: 20) {
                
                // Texte + Lien "Changer de numéro"
                VStack(spacing: 4) {
                    Text("login_label_change_phone_question".localized) // "Vous avez changé de numéro de téléphone?"
                        .font(.entourageTitle(16)) // Un peu plus gras comme sur la maquette
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        vm.onChangePhone?()
                    }) {
                        Text("login_button_change_phone".localized) // "Changer mon numéro"
                            .font(.custom("NunitoSans-Regular", size: 15))
                            .foregroundColor(.black)
                            .underline()
                    }
                }
                
                // Bouton Login Principal
                Button(action: {
                    vm.validateAndLogin()
                    UIApplication.shared.endEditing()
                }) {
                    Text("login_button_connect".localized) // "Je me connecte"
                        .font(.custom("Quicksand-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(height: 54) // Un peu plus haut
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.appOrange))
                        .cornerRadius(27)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 20) // Marge du bas
        }
        .background(Color.white)
        // Alert Standard
        .alert(isPresented: $vm.showAlert) {
            Alert(
                title: Text("attention_pop_title".localized),
                message: Text(vm.alertMessage ?? ""),
                dismissButton: .default(Text("close".localized))
            )
        }
        // Alert Confirmation Renvoi
        .background(
            EmptyView().alert(isPresented: $vm.showResendConfirmation) {
                let phoneFull = "\(vm.selectedCountry.code) \(vm.phone)"
                return Alert(
                    title: Text("login_resend_code_title".localized),
                    message: Text("login_resend_code_message".localized + phoneFull),
                    primaryButton: .default(Text("login_resend_code_button_yes".localized), action: {
                        vm.confirmResendCode()
                    }),
                    secondaryButton: .cancel(Text("login_resend_code_button_no".localized))
                )
            }
        )
        .onDisappear {
            vm.stopTimer()
        }
    }
}

// MARK: - UIViewController Wrapper

final class OTLoginV2ViewController: UIHostingController<LoginView> {
    
    private let vm = LoginViewModel()
    
    // Compatibilité API externe (pour le routeur)
    var hasKeychain: Bool = false {
        didSet {
            if hasKeychain {
                vm.checkForKeychain()
            }
        }
    }
    
    // Deeplink handling variable
    var deeplink: URL? = nil
    
    init() {
        super.init(rootView: LoginView(vm: vm))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: LoginView(vm: vm))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuration de la vue racine (fond transparent pour laisser SwiftUI gérer)
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Binding des actions ViewModel -> Navigation Controller
        setupCallbacks()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setupCallbacks() {
        // Navigation Back
        vm.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        // Navigation Change Phone
        vm.onChangePhone = { [weak self] in
            guard let self = self else { return }
            
            // Charge explicitement le Storyboard "Intro"
            let sb = UIStoryboard(name: "Intro", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "ChangePhoneVC")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        // Logic Success Login
        vm.onSuccess = { [weak self] in
            guard let self = self else { return }
            
            // Logique héritée de l'ancien VC
            AppState.continueFromLoginVC()
            
            if let link = self.deeplink {
                // OTDeepLinkService.init().handleDeepLink(link) // Décommenter si le service est dispo
                self.deeplink = nil
            }
        }
    }
}
