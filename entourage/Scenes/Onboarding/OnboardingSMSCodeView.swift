import SwiftUI
import UIKit

// MARK: - Fonts SwiftUI (Quicksand‑Bold & NunitoSans‑Regular)
//
// Définition des polices utilisées dans cette vue. Comme dans les autres
// écrans de l’onboarding, les titres utilisent Quicksand‑Bold taille 20
// et le corps utilise NunitoSans‑Regular taille 15.
private extension Font {
    static func entourageTitle(_ size: CGFloat = 20) -> Font {
        .custom("Quicksand-Bold", size: size)
    }
    static func entourageBody(_ size: CGFloat = 15) -> Font {
        .custom("NunitoSans-Regular", size: size)
    }
}

/// Écran de saisie du code SMS. Ce composant est présenté après la
/// validation du numéro de téléphone. Il affiche un rappel du numéro
/// formaté, permet à l’utilisateur de saisir un code à six chiffres,
/// indique un compte à rebours avant de pouvoir redemander un code et
/// propose des liens vers l’aide et les conditions d’utilisation. Les
/// marges latérales sont fixées à 20 points et les espaces verticaux
/// principaux à 20 points afin de s’accorder avec le reste de
/// l’onboarding.
struct OnboardingSMSCodeView: View {
    // MARK: - Inputs

    let phone: String
    let timeRemaining: Int      // secondes restantes avant retry
    let canRetry: Bool          // vrai quand on peut redemander un code

    let onCodeFilled: (String) -> Void
    let onRequestNewCode: () -> Void
    let onModifyPhone: () -> Void // encore là même si plus utilisé

    // MARK: - State

    @State private var code: String = ""
    @State private var isEditing: Bool = false

    // MARK: - Phone formatting

    /// Format façon Android : 0X XX XX XX XX
    private var formattedPhone: String {
        let digits = phone.filter { $0.isNumber }
        let normalized: String

        if digits.hasPrefix("0") {
            normalized = digits
        } else if digits.hasPrefix("33"), digits.count > 2 {
            normalized = "0" + digits.dropFirst(2)
        } else if phone.hasPrefix("+33"), digits.count > 2 {
            normalized = "0" + digits.dropFirst(2)
        } else {
            normalized = digits
        }

        let limited = String(normalized.prefix(10))
        return limited.chunked(size: 2).joined(separator: " ")
    }

    // 00:05, 00:27, etc.
    private var formattedCountdown: String {
        String(format: "00:%02d", max(timeRemaining, 0))
    }

    /// Texte au-dessus du lien "Renvoyer le code"
    ///
    /// Localisable attendu :
    ///  - "onboard_sms_view_wait_countdown" = "Vous pourrez demander un nouveau code dans %@";
    ///  - "onboard_sms_view_wait_ready" = "Vous pouvez demander un nouveau code.";
    private var retryTitle: String {
        if canRetry {
            return NSLocalizedString("onboard_sms_view_wait_ready",
                                     comment: "Texte quand on peut redemander un code")
        } else {
            let template = NSLocalizedString("onboard_sms_view_wait_countdown",
                                             comment: "Texte avec compte à rebours")
            return String(format: template, formattedCountdown)
        }
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // --- Titre + numéro ---
                VStack(alignment: .leading, spacing: 8) {
                    Text("onboard_sms_view_title")
                        .font(.entourageTitle(20))
                        .foregroundColor(.black)

                    Text("onboard_sms_view_sub")
                        .font(.entourageBody(15))
                        .foregroundColor(Color(UIColor.appGrey151))

                    HStack(spacing: 8) {
                        Text(formattedPhone)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                        // Si un jour tu veux remettre "Modifier", on a encore onModifyPhone()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                // top à 60 comme demandé / Phase1-like
                .padding(.top, 20)
                .padding(.bottom, 8)

                // --- OTP : 6 cases séparées ---
                otpRow
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                // --- Bloc "Vous n'avez pas reçu votre code ?" avec timer ---
                VStack(spacing: 8) {
                    Text(retryTitle)
                        .font(.entourageBody(15))
                        .foregroundColor(Color(UIColor.appGrey151))
                        .multilineTextAlignment(.center)

                    Button(action: {
                        if canRetry {
                            onRequestNewCode()
                        }
                    }) {
                        Text("onboard_retry_view_link")
                            .font(.entourageBody(15))
                            .foregroundColor(Color(UIColor.appOrange))
                            .underline(canRetry, color: Color(UIColor.appOrange))
                            .multilineTextAlignment(.center)
                            .opacity(canRetry ? 1.0 : 0.4)
                    }
                    .disabled(!canRetry)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // --- Bloc aide ---
                VStack(spacing: 4) {
                    Text("onboard_help_view_title")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(UIColor.appBlack30))

                    Button(action: { openHelpEmail() }) {
                        Text("onboard_help_view_link")
                            .font(.entourageBody(15))
                            .foregroundColor(.black)
                            .underline()
                    }
                }
                .padding(.top, 20)

                // --- CGU / Politique de confidentialité ---
                termsAndConditionsView
                    .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.bottom, 32)
        }
    }

    // MARK: - OTP row (6 cases)

    private var otpRow: some View {
        ZStack {
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(UIColor.appPaleGrey), lineWidth: 1)
                            )

                        Text(digitText(at: index))
                            .font(.system(size: 20))
                            .foregroundColor(digitColor(at: index))
                    }
                    .frame(height: 60)
                }
            }

            // Champ caché qui reçoit le texte
            HiddenOTPTextField(text: $code, isFirstResponder: $isEditing)
                .frame(width: 0, height: 0)
                .opacity(0.01)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Tap sur la rangée → on met le focus
            isEditing = true
        }
        .onChange(of: code) { newValue in
            if newValue.count == 6 {
                onCodeFilled(newValue)
                hideKeyboard()
                isEditing = false
            }
        }
    }

    private func digitText(at index: Int) -> String {
        // Si un chiffre est saisi pour cette case → on l'affiche
        if index < code.count {
            let idx = code.index(code.startIndex, offsetBy: index)
            return String(code[idx])
        }
        // Curseur visuel dans la case active
        if index == code.count && isEditing && code.count < 6 {
            return "|"
        }
        // Sinon la case reste vide
        return ""
    }

    private func digitColor(at index: Int) -> Color {
        if index < code.count {
            return Color(UIColor.appBlack30)
        } else {
            return Color(UIColor.appGrey165).opacity(0.5)
        }
    }

    // MARK: - Terms and Conditions View

    private var termsAndConditionsView: some View {
        VStack(spacing: 4) {
            (Text("En vous inscrivant, vous acceptez nos ")
                .foregroundColor(Color(UIColor.appGrey151))
             +
             Text("Conditions Générales d'Utilisation")
                .foregroundColor(Color(UIColor.appOrange))
                .underline()
             +
             Text(" et notre ")
                .foregroundColor(Color(UIColor.appGrey151))
             +
             Text("Politique de confidentialité")
                .foregroundColor(Color(UIColor.appOrange))
                .underline()
             +
             Text(".")
                .foregroundColor(Color(UIColor.appGrey151))
            )
            .font(.system(size: 12))
            .multilineTextAlignment(.center)
            .onTapGesture {
                // Pour détecter où l'utilisateur a tapé, on ouvre un menu
                showTermsActionSheet()
            }
        }
    }

    private func showTermsActionSheet() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let rootVC = window.rootViewController else { return }

        let alert = UIAlertController(title: "Ouvrir", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Conditions Générales d'Utilisation", style: .default) { _ in
            openURL("https://www.entourage.social/conditions-generales-dutilisation")
        })

        alert.addAction(UIAlertAction(title: "Politique de confidentialité", style: .default) { _ in
            openURL("https://www.entourage.social/politique-de-confidentialite")
        })

        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))

        rootVC.present(alert, animated: true)
    }

    // MARK: - Actions auxiliaires

    private func openHelpEmail() {
        let email = "contact@entourage.social"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }

    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
    }
}

// MARK: - Champ caché

private struct HiddenOTPTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFirstResponder: Bool

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.keyboardType = .numberPad
        tf.textContentType = .oneTimeCode
        tf.delegate = context.coordinator
        tf.addTarget(context.coordinator,
                     action: #selector(Coordinator.textChanged),
                     for: .editingChanged)
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        if isFirstResponder && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        @objc func textChanged(_ sender: UITextField) {
            let digits = sender.text?.filter { $0.isNumber } ?? ""
            let limited = String(digits.prefix(6))
            if limited != text {
                text = limited
            }
            sender.text = limited
        }

        func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {

            let current = textField.text ?? ""
            guard let stringRange = Range(range, in: current) else { return false }

            let updated = current.replacingCharacters(in: stringRange, with: string)
            let digits = updated.filter { $0.isNumber }
            let limited = String(digits.prefix(6))

            text = limited
            textField.text = limited

            return false
        }
    }
}

// MARK: - Helper

private extension String {
    func chunked(size: Int) -> [String] {
        guard size > 0 else { return [self] }
        var result: [String] = []
        var index = startIndex
        while index < endIndex {
            let end = self.index(index, offsetBy: size, limitedBy: endIndex) ?? endIndex
            result.append(String(self[index..<end]))
            index = end
        }
        return result
    }
}
