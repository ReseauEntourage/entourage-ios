import SwiftUI
import UIKit

struct OnboardingSMSCodeView: View {
    let phone: String
    let timeRemaining: Int      // secondes restantes avant retry
    let canRetry: Bool          // vrai quand on peut redemander un code

    let onCodeFilled: (String) -> Void
    let onRequestNewCode: () -> Void
    let onModifyPhone: () -> Void // encore là même si plus utilisé, ce n’est pas grave

    @State private var code: String = ""
    @State private var isEditing: Bool = false

    // Format façon Android : 0X XX XX XX XX
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
    /// → à adapter avec tes Localizable.strings :
    ///   - "onboard_sms_view_wait_countdown" = "Vous pourrez demander un nouveau code dans %@";
    ///   - "onboard_sms_view_wait_ready" = "Vous pouvez demander un nouveau code.";
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

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // --- Titre + numéro ---
                VStack(alignment: .leading, spacing: 8) {
                    Text("onboard_sms_view_title")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(UIColor.appBlack30))

                    Text("onboard_sms_view_sub")
                        .font(.system(size: 15))
                        .foregroundColor(Color(UIColor.appGrey151))

                    HStack(spacing: 8) {
                        Text(formattedPhone)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(UIColor.appBlack30))
                        // 👉 plus de bouton "Modifier", juste le numéro
                        // si un jour tu veux le remettre :
                        // Button(action: { onModifyPhone() }) { Text("onboard_sms_view_edit") ... }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // --- OTP : 6 cases séparées ---
                otpRow
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                // --- Bloc “Vous n’avez pas reçu votre code ?” avec timer ---
                VStack(spacing: 8) {
                    Text(retryTitle)
                        .font(.system(size: 15))
                        .foregroundColor(Color(UIColor.appGrey151))
                        .multilineTextAlignment(.center)

                    Button(action: {
                        if canRetry {
                            onRequestNewCode()
                        }
                    }) {
                        Text("onboard_retry_view_link")
                            .font(.system(size: 15))
                            .foregroundColor(Color(UIColor.appOrange))
                            .underline(canRetry, color: Color(UIColor.appOrange))
                            .multilineTextAlignment(.center)
                            .opacity(canRetry ? 1.0 : 0.4)
                    }
                    .disabled(!canRetry)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // --- Bloc aide ---
                VStack(spacing: 4) {
                    Text("onboard_help_view_title")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(UIColor.appBlack30))

                    Button(action: { openHelpEmail() }) {
                        Text("onboard_help_view_link")
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                            .underline()
                    }
                }
                .padding(.top, 28)

                // --- CGU / Politique de confidentialité ---
                // On affiche une phrase récapitulant l’acceptation des conditions
                // générales d’utilisation et de la politique de confidentialité.
                // Ce texte est centré et de petite taille pour ne pas surcharger l’interface.
                Text("En continuant, vous acceptez les Conditions Générales d’Utilisation et la politique de confidentialité.")
                    .font(.system(size: 12))
                    .foregroundColor(Color(UIColor.appGrey151))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

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
        // Retourne le caractère à afficher pour chaque case du code.
        // Si la case correspond à un chiffre saisi, on retourne ce chiffre.
        if index < code.count {
            let idx = code.index(code.startIndex, offsetBy: index)
            return String(code[idx])
        }
        // Si aucune saisie pour cette case et qu’elle est la prochaine à saisir,
        // on affiche un curseur simple pour indiquer le focus.
        if index == code.count && isEditing && code.count < 6 {
            return "|"
        }
        // Sinon on laisse la case vide
        return ""
    }

    private func digitColor(at index: Int) -> Color {
        if index < code.count {
            return Color(UIColor.appBlack30)
        } else {
            return Color(UIColor.appGrey165).opacity(0.5)
        }
    }

    // MARK: - Actions auxiliaires

    private func openHelpEmail() {
        let email = "contact@entourage.social"
        if let url = URL(string: "mailto:\(email)") {
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
