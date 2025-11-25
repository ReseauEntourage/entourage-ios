import SwiftUI
import UIKit

struct OnboardingSMSCodeView: View {
    let phone: String
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
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // --- OTP : 6 cases séparées ---
                otpRow
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                // --- Bloc “Vous n’avez pas reçu votre code ?” ---
                VStack(spacing: 8) {
                    Text("onboard_sms_view_wait_title")
                        .font(.system(size: 15))
                        .foregroundColor(Color(UIColor.appGrey151))
                        .multilineTextAlignment(.center)

                    Button(action: { onRequestNewCode() }) {
                        Text("onboard_retry_view_link")
                            .font(.system(size: 15))
                            .foregroundColor(Color(UIColor.appOrange))
                            .underline()
                            .multilineTextAlignment(.center)
                    }
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
        if index < code.count {
            let idx = code.index(code.startIndex, offsetBy: index)
            return String(code[idx])
        } else {
            return "0"
        }
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
