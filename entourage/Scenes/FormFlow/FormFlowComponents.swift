//
//  FormFlowComponents.swift
//  entourage
//
//  Composants SwiftUI partagés par les étapes des parcours de création / modification
//  (événement : refonte EN-9578, puis groupe et entraide : change flux-creation-unifie).
//  Typographie de l'app (Nunito Sans pour les textes, Quicksand Bold pour les titres) ; l'orange est réservé au bouton d'action, à la barre de progression,
//  à la bascule présentiel / en ligne et aux petites icônes ; sélection et focus en noir.
//
//  Cartes sélectionnables : même idée que les cartes d'intérêts de l'onboarding enrichi
//  (`InterestsCollectionViewCell` : bordure fine, coche à droite), avec sélection en noir.
//

import SwiftUI
import UIKit
import SDWebImage

// MARK: - Style -

enum FormFlowStyle {
    static let ink = Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
    static let ink2 = Color(red: 106 / 255, green: 106 / 255, blue: 106 / 255)
    static let ink3 = Color(red: 154 / 255, green: 154 / 255, blue: 154 / 255)
    static let line = Color(red: 221 / 255, green: 221 / 255, blue: 221 / 255)
    static let line2 = Color(red: 235 / 255, green: 235 / 255, blue: 235 / 255)
    static let tint = Color(red: 247 / 255, green: 245 / 255, blue: 243 / 255)
    static let errorText = Color(red: 196 / 255, green: 43 / 255, blue: 48 / 255)
    static let errorBorder = Color(red: 229 / 255, green: 72 / 255, blue: 77 / 255)
    static let accent = Color(UIColor.appOrange)
    static let accentSoft = Color(red: 254 / 255, green: 234 / 255, blue: 227 / 255)

    static let uiInk = UIColor(red: 34 / 255, green: 34 / 255, blue: 34 / 255, alpha: 1)
    static let uiInk2 = UIColor(red: 106 / 255, green: 106 / 255, blue: 106 / 255, alpha: 1)
    static let uiInk3 = UIColor(red: 154 / 255, green: 154 / 255, blue: 154 / 255, alpha: 1)
    static let uiLine2 = UIColor(red: 235 / 255, green: 235 / 255, blue: 235 / 255, alpha: 1)

    static func regular(_ size: CGFloat) -> Font { Font(ApplicationTheme.getFontNunitoRegular(size: size)) }
    static func semibold(_ size: CGFloat) -> Font { Font(ApplicationTheme.getFontNunitoSemiBold(size: size)) }
    static func bold(_ size: CGFloat) -> Font { Font(ApplicationTheme.getFontNunitoBold(size: size)) }
    static func title(_ size: CGFloat) -> Font { Font(ApplicationTheme.getFontQuickSandBold(size: size)) }

    /// Premier symbole SF disponible sur l'OS courant (certains symboles n'existent qu'à partir d'iOS 16).
    static func symbol(_ names: [String]) -> String {
        return names.first { UIImage(systemName: $0) != nil } ?? names.last ?? "circle"
    }

    static func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - En-tête d'étape -

struct FormFlowStepHeader: View {
    let eyebrow: String
    let title: String
    var isSmall = false

    /// « Étape N sur X » + titre de l'étape (la position et le total viennent de la liste d'étapes du parcours).
    init(position: Int, count: Int, titleKey: String) {
        self.eyebrow = String(format: "event_form_step_label".localized, position, count)
        self.title = titleKey.localized
    }

    init(eyebrow: String, title: String, isSmall: Bool = false) {
        self.eyebrow = eyebrow
        self.title = title
        self.isSmall = isSmall
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow)
                .font(FormFlowStyle.semibold(12.5))
                .foregroundColor(FormFlowStyle.ink2)
            Text(title)
                .font(FormFlowStyle.title(isSmall ? 21 : 24))
                .foregroundColor(FormFlowStyle.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 24)
    }
}

// MARK: - Libellés, erreurs -

struct FormFlowLabel: View {
    let title: String
    var isRequired = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(title)
                .font(FormFlowStyle.bold(13))
                .foregroundColor(FormFlowStyle.ink)
            if isRequired {
                Text("event_form_required".localized)
                    .font(FormFlowStyle.regular(11.5))
                    .foregroundColor(FormFlowStyle.ink3)
            }
        }
        .padding(.bottom, 8)
    }
}

struct FormFlowHint: View {
    let text: String
    var body: some View {
        Text(text)
            .font(FormFlowStyle.regular(12.5))
            .foregroundColor(FormFlowStyle.ink2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 9)
    }
}

/// Erreur sous le champ : rouge, avec icône.
struct FormFlowErrorText: View {
    let message: String
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 14, weight: .regular))
                .padding(.top, 1)
            Text(message)
                .font(FormFlowStyle.regular(12.5))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundColor(FormFlowStyle.errorText)
        .padding(.top, 7)
        .accessibility(label: Text(message))
    }
}

extension View {
    /// Affiche l'erreur d'un champ sous la vue, si elle existe.
    func formFlowError(_ message: String?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            self
            if let message = message {
                FormFlowErrorText(message: message)
            }
        }
    }
}

// MARK: - Champ de saisie -

struct FormFlowInputBox<Content: View>: View {
    var hasError = false
    var isFocused = false
    var padded = true
    var minHeight: CGFloat = 54
    let content: Content

    init(hasError: Bool = false, isFocused: Bool = false, padded: Bool = true, minHeight: CGFloat = 54, @ViewBuilder content: () -> Content) {
        self.hasError = hasError
        self.isFocused = isFocused
        self.padded = padded
        self.minHeight = minHeight
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, padded ? 15 : 0)
            .padding(.vertical, padded ? 14 : 0)
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: (hasError || isFocused) ? 2 : 1)
            )
    }

    private var borderColor: Color {
        if hasError { return FormFlowStyle.errorBorder }
        if isFocused { return FormFlowStyle.ink }
        return FormFlowStyle.line
    }
}

/// Champ texte sur une ligne (nom, lien de connexion, adresse...).
struct FormFlowTextField: View {
    let placeholder: String
    @Binding var text: String
    var hasError = false
    /// Icône à l'extrémité droite du champ.
    var trailingSystemImage: String? = nil
    var keyboard: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .sentences
    @State private var isFocused = false

    var body: some View {
        FormFlowInputBox(hasError: hasError, isFocused: isFocused) {
            HStack(spacing: 10) {
                TextField(placeholder, text: $text, onEditingChanged: { editing in
                    isFocused = editing
                })
                .font(FormFlowStyle.regular(15.5))
                .foregroundColor(FormFlowStyle.ink)
                .keyboardType(keyboard)
                .autocapitalization(autocapitalization)
                .disableAutocorrection(keyboard == .URL)
                if let image = trailingSystemImage {
                    Spacer(minLength: 0)
                    Image(systemName: image)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(FormFlowStyle.accent)
                }
            }
        }
    }
}

// MARK: - Zone de texte (description) -

struct FormFlowTextArea: View {
    let placeholder: String
    @Binding var text: String
    var maxLength: Int
    var hasError = false
    @State private var isFocused = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            FormFlowInputBox(hasError: hasError, isFocused: isFocused, padded: false, minHeight: 112) {
                ZStack(alignment: .topLeading) {
                    FormFlowTextViewRepresentable(text: $text, maxLength: maxLength, onFocusChange: { isFocused = $0 })
                        .frame(height: 112)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                    if text.isEmpty {
                        Text(placeholder)
                            .font(FormFlowStyle.regular(15.5))
                            .foregroundColor(FormFlowStyle.ink3)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 14)
                            .allowsHitTesting(false)
                    }
                }
            }
            Text("\(text.count) / \(maxLength)")
                .font(FormFlowStyle.regular(11))
                .foregroundColor(FormFlowStyle.ink3)
        }
    }
}

private struct FormFlowTextViewRepresentable: UIViewRepresentable {
    @Binding var text: String
    let maxLength: Int
    let onFocusChange: (Bool) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.font = ApplicationTheme.getFontNunitoRegular(size: 15.5)
        textView.textColor = FormFlowStyle.uiInk
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        textView.textContainer.lineFragmentPadding = 5
        textView.autocapitalizationType = .sentences
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.parent = self
        if uiView.text != text {
            uiView.text = text
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: FormFlowTextViewRepresentable
        init(_ parent: FormFlowTextViewRepresentable) { self.parent = parent }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textViewDidBeginEditing(_ textView: UITextView) { parent.onFocusChange(true) }
        func textViewDidEndEditing(_ textView: UITextView) { parent.onFocusChange(false) }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let current = textView.text as NSString
            let updated = current.replacingCharacters(in: range, with: text)
            return updated.count <= parent.maxLength
        }
    }
}

// MARK: - Champ date / heure (roue de sélection) -

struct FormFlowPickerField: View {
    enum Mode { case date, time }

    let mode: Mode
    let placeholder: String
    let text: String
    let trailingSystemImage: String
    var hasError = false
    /// Valeur affichée à l'ouverture de la roue quand le champ est vide.
    var defaultDate: Date
    var currentDate: Date? = nil
    var minimumDate: Date? = nil
    var maximumDate: Date? = nil
    let onCommit: (Date) -> Void
    @State private var isFocused = false

    var body: some View {
        FormFlowInputBox(hasError: hasError, isFocused: isFocused, padded: false) {
            ZStack(alignment: .trailing) {
                Color.clear.frame(maxWidth: .infinity, minHeight: 54)
                FormFlowPickerTextField(
                    mode: mode,
                    placeholder: placeholder,
                    text: text,
                    defaultDate: defaultDate,
                    currentDate: currentDate,
                    minimumDate: minimumDate,
                    maximumDate: maximumDate,
                    onFocusChange: { isFocused = $0 },
                    onCommit: onCommit
                )
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                Image(systemName: trailingSystemImage)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(FormFlowStyle.accent)
                    .padding(.trailing, 14)
                    .allowsHitTesting(false)
            }
        }
    }
}

private final class FormFlowInsetTextField: UITextField {
    var insets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 44)
    override func textRect(forBounds bounds: CGRect) -> CGRect { return bounds.inset(by: insets) }
    override func editingRect(forBounds bounds: CGRect) -> CGRect { return bounds.inset(by: insets) }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect { return bounds.inset(by: insets) }
    override func caretRect(for position: UITextPosition) -> CGRect { return .zero }
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] { return [] }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool { return false }
}

private struct FormFlowPickerTextField: UIViewRepresentable {
    let mode: FormFlowPickerField.Mode
    let placeholder: String
    let text: String
    let defaultDate: Date
    let currentDate: Date?
    let minimumDate: Date?
    let maximumDate: Date?
    let onFocusChange: (Bool) -> Void
    let onCommit: (Date) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UITextField {
        let textField = FormFlowInsetTextField()
        textField.delegate = context.coordinator
        textField.font = ApplicationTheme.getFontNunitoRegular(size: 15.5)
        textField.textColor = FormFlowStyle.uiInk
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let picker = UIDatePicker()
        picker.datePickerMode = mode == .date ? .date : .time
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale.getPreferredLocale()
        context.coordinator.picker = picker
        textField.inputView = picker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancel = UIBarButtonItem(title: "cancel".localized, style: .plain, target: context.coordinator, action: #selector(Coordinator.cancel))
        cancel.tintColor = .appOrangeLight
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "validate".localized, style: .plain, target: context.coordinator, action: #selector(Coordinator.validate))
        done.tintColor = .appOrange
        toolbar.setItems([cancel, space, done], animated: false)
        textField.inputAccessoryView = toolbar
        context.coordinator.textField = textField
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.parent = self
        uiView.text = text
        uiView.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: FormFlowStyle.uiInk3, .font: ApplicationTheme.getFontNunitoRegular(size: 15.5)]
        )
        context.coordinator.picker?.minimumDate = minimumDate
        context.coordinator.picker?.maximumDate = maximumDate
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: FormFlowPickerTextField
        weak var picker: UIDatePicker?
        weak var textField: UITextField?

        init(_ parent: FormFlowPickerTextField) { self.parent = parent }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            picker?.minimumDate = parent.minimumDate
            picker?.maximumDate = parent.maximumDate
            picker?.date = parent.currentDate ?? parent.defaultDate
            parent.onFocusChange(true)
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onFocusChange(false)
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            return false
        }

        @objc func validate() {
            if let date = picker?.date { parent.onCommit(date) }
            textField?.resignFirstResponder()
        }

        @objc func cancel() {
            textField?.resignFirstResponder()
        }
    }
}

// MARK: - Cartes, pastilles, radios -

/// Carte sélectionnable (accessibilité et public). Sélection en noir, comme sur la maquette.
struct FormFlowSelectableCard: View {
    let symbolNames: [String]
    /// Image du catalogue d'assets (remplace le symbole SF quand elle est renseignée).
    var assetImageName: String? = nil
    let title: String
    var subtitle: String? = nil
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(FormFlowStyle.accentSoft)
                    if let asset = assetImageName, !asset.isEmpty, UIImage(named: asset) != nil {
                        Image(asset)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                    }
                    else {
                        Image(systemName: FormFlowStyle.symbol(symbolNames))
                            .font(.system(size: 19, weight: .regular))
                            .foregroundColor(FormFlowStyle.accent)
                    }
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(FormFlowStyle.bold(14.5))
                        .foregroundColor(FormFlowStyle.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(FormFlowStyle.regular(12))
                            .foregroundColor(FormFlowStyle.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 8)

                ZStack {
                    Circle()
                        .fill(isOn ? FormFlowStyle.ink : Color.white)
                    Circle()
                        .stroke(isOn ? FormFlowStyle.ink : FormFlowStyle.line, lineWidth: 1.8)
                    if isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 24, height: 24)
            }
            .padding(isOn ? 13 : 14)
            .background(isOn ? FormFlowStyle.accentSoft.opacity(0.55) : Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isOn ? FormFlowStyle.ink : FormFlowStyle.line, lineWidth: isOn ? 3 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(addTraits: isOn ? [.isButton, .isSelected] : [.isButton])
    }
}

struct FormFlowChip: View {
    let title: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FormFlowStyle.semibold(14))
                .foregroundColor(isOn ? .white : FormFlowStyle.ink)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(isOn ? FormFlowStyle.ink : Color.white)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isOn ? FormFlowStyle.ink : FormFlowStyle.line, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(addTraits: isOn ? [.isButton, .isSelected] : [.isButton])
    }
}

struct FormFlowRadioRow: View {
    let title: String
    let isOn: Bool
    let showsSeparator: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack(spacing: 13) {
                    ZStack {
                        Circle().stroke(isOn ? FormFlowStyle.ink : FormFlowStyle.line, lineWidth: 2)
                        if isOn {
                            Circle().fill(FormFlowStyle.ink).frame(width: 11, height: 11)
                        }
                    }
                    .frame(width: 22, height: 22)
                    Text(title)
                        .font(FormFlowStyle.regular(15))
                        .foregroundColor(FormFlowStyle.ink)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 13)
                .contentShape(Rectangle())
                if showsSeparator {
                    Rectangle().fill(FormFlowStyle.line2).frame(height: 1)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(addTraits: isOn ? [.isButton, .isSelected] : [.isButton])
    }
}

/// Mise en page « retour à la ligne » pour les pastilles (compatible iOS 14).
struct FormFlowLayout<Item: Hashable, Content: View>: View {
    let items: [Item]
    var spacing: CGFloat = 9
    let content: (Item) -> Content
    @State private var totalHeight: CGFloat = 0

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generate(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }

    private func generate(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                content(item)
                    .padding(.trailing, spacing)
                    .padding(.bottom, spacing)
                    .alignmentGuide(.leading, computeValue: { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= dimension.height
                        }
                        let result = width
                        if item == items.last {
                            width = 0
                        } else {
                            width -= dimension.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if item == items.last {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(
            GeometryReader { proxy -> Color in
                DispatchQueue.main.async {
                    if totalHeight != proxy.size.height {
                        totalHeight = proxy.size.height
                    }
                }
                return Color.clear
            }
        )
    }
}

// MARK: - Image distante / locale -

struct FormFlowRemoteImage: UIViewRepresentable {
    let urlString: String?

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        if let urlString = urlString, !urlString.isEmpty, let url = URL(string: urlString) {
            uiView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder_photo_group"))
        }
        else {
            uiView.image = nil
        }
    }
}

// MARK: - Photo (étape 1 et aperçu) -

/// Image de l'événement : photo locale, sinon photo distante. `nil` si rien à afficher.
struct FormFlowPhotoImage: View {
    let localImage: UIImage?
    let remoteUrl: String?

    var hasImage: Bool {
        return localImage != nil || !(remoteUrl ?? "").isEmpty
    }

    var body: some View {
        if let localImage = localImage {
            Image(uiImage: localImage)
                .resizable()
                .scaledToFill()
        }
        else {
            FormFlowRemoteImage(urlString: remoteUrl)
        }
    }
}

// MARK: - Sélecteur de photo (étape photo des parcours groupe et entraide) -

/// Tuile « Ajouter / Modifier la photo » : image choisie en grand avec « Modifier », sinon zone en pointillés.
struct FormFlowPhotoPickerTile: View {
    let localImage: UIImage?
    let remoteUrl: String?
    let hasPhoto: Bool
    let hasError: Bool
    let addTitle: String
    let changeTitle: String
    var addedCaption: String? = nil
    var height: CGFloat = 190
    let action: () -> Void

    var body: some View {
        let photo = FormFlowPhotoImage(localImage: localImage, remoteUrl: remoteUrl)
        Button(action: action) {
            if hasPhoto && photo.hasImage {
                ZStack(alignment: .bottomTrailing) {
                    photo
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .clipped()
                    Text(changeTitle)
                        .font(FormFlowStyle.semibold(12.5))
                        .foregroundColor(FormFlowStyle.ink)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(10)
                }
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(FormFlowStyle.line, lineWidth: 1))
            }
            else {
                VStack(spacing: 7) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 13).fill(FormFlowStyle.accentSoft)
                        Image(systemName: hasPhoto ? "checkmark" : "photo")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(FormFlowStyle.accent)
                    }
                    .frame(width: 46, height: 46)

                    Text(hasPhoto ? changeTitle : addTitle)
                        .font(FormFlowStyle.bold(13.5))
                        .foregroundColor(FormFlowStyle.ink)
                        .underline()
                    if hasPhoto, let caption = addedCaption {
                        Text(caption)
                            .font(FormFlowStyle.regular(12))
                            .foregroundColor(FormFlowStyle.ink2)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(hasError ? FormFlowStyle.errorBorder : FormFlowStyle.line,
                                style: StrokeStyle(lineWidth: hasError ? 1.5 : 1, dash: hasError ? [] : [5, 4]))
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Champ lieu (ouvre le sélecteur de lieu de l'app) -

struct FormFlowPlaceField: View {
    let placeholder: String
    let text: String
    var hasError = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            FormFlowInputBox(hasError: hasError) {
                HStack(spacing: 10) {
                    Text(text.isEmpty ? placeholder : text)
                        .font(FormFlowStyle.regular(15.5))
                        .foregroundColor(text.isEmpty ? FormFlowStyle.ink3 : FormFlowStyle.ink)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(FormFlowStyle.accent)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Aperçu : lignes et pastilles -

struct FormFlowMetaRow: View {
    let systemImage: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(FormFlowStyle.ink2)
                .frame(width: 16)
                .padding(.top, 2)
            Text(text)
                .font(FormFlowStyle.regular(13.5))
                .foregroundColor(FormFlowStyle.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 6)
    }
}

struct FormFlowPreviewChip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(FormFlowStyle.semibold(11.5))
            .foregroundColor(FormFlowStyle.ink)
            .padding(.horizontal, 11)
            .padding(.vertical, 5)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(FormFlowStyle.line, lineWidth: 1))
    }
}

/// Photo d'aperçu (bandeau arrondi, pastille d'image si rien à afficher).
struct FormFlowPreviewPhoto: View {
    let localImage: UIImage?
    let remoteUrl: String?
    var height: CGFloat = 158

    var body: some View {
        let image = FormFlowPhotoImage(localImage: localImage, remoteUrl: remoteUrl)
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 243 / 255, green: 236 / 255, blue: 230 / 255), Color(red: 231 / 255, green: 221 / 255, blue: 211 / 255)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            if image.hasImage {
                image
            }
            else {
                Image(systemName: "photo")
                    .font(.system(size: 34, weight: .light))
                    .foregroundColor(FormFlowStyle.ink3)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
        .cornerRadius(16)
    }
}

// MARK: - Page d'étape générique (hébergement SwiftUI) -

/// Écran d'une étape ou de l'aperçu : héberge la vue SwiftUI du parcours.
final class FormFlowHostViewController<Content: View>: UIViewController {
    private let content: Content

    init(_ content: Content) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        embedSwiftUI(content)
    }
}

// MARK: - Hébergement SwiftUI dans un UIViewController -

extension UIViewController {
    /// Intègre une vue SwiftUI en plein cadre dans la vue du contrôleur.
    @discardableResult
    func embedSwiftUI<V: View>(_ rootView: V) -> UIHostingController<V> {
        let hosting = UIHostingController(rootView: rootView)
        addChild(hosting)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .white
        view.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hosting.didMove(toParent: self)
        return hosting
    }
}
