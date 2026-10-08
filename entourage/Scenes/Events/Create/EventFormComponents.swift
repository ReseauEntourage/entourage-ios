//
//  EventFormComponents.swift
//  entourage
//
//  Composants SwiftUI partagés par les étapes de création / modification d'événement
//  (refonte EN-9578). Typographie de l'app (Nunito Sans pour les textes, Quicksand Bold
//  pour les titres) ; l'orange est réservé au bouton d'action, à la barre de progression,
//  à la bascule présentiel / en ligne et aux petites icônes ; sélection et focus en noir.
//
//  Cartes sélectionnables : même idée que les cartes d'intérêts de l'onboarding enrichi
//  (`InterestsCollectionViewCell` : bordure fine, coche à droite), avec sélection en noir.
//

import SwiftUI
import UIKit
import SDWebImage

// MARK: - Style -

enum EventFormStyle {
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

struct EventStepHeader: View {
    let eyebrow: String
    let title: String
    var isSmall = false

    init(step: EventCreateStep) {
        self.eyebrow = String(format: "event_form_step_label".localized, step.position, EventCreateStep.count)
        self.title = step.titleKey.localized
    }

    init(eyebrow: String, title: String, isSmall: Bool = false) {
        self.eyebrow = eyebrow
        self.title = title
        self.isSmall = isSmall
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow)
                .font(EventFormStyle.semibold(12.5))
                .foregroundColor(EventFormStyle.ink2)
            Text(title)
                .font(EventFormStyle.title(isSmall ? 21 : 24))
                .foregroundColor(EventFormStyle.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 24)
    }
}

// MARK: - Libellés, erreurs -

struct EventFormLabel: View {
    let title: String
    var isRequired = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(title)
                .font(EventFormStyle.bold(13))
                .foregroundColor(EventFormStyle.ink)
            if isRequired {
                Text("event_form_required".localized)
                    .font(EventFormStyle.regular(11.5))
                    .foregroundColor(EventFormStyle.ink3)
            }
        }
        .padding(.bottom, 8)
    }
}

struct EventFormHint: View {
    let text: String
    var body: some View {
        Text(text)
            .font(EventFormStyle.regular(12.5))
            .foregroundColor(EventFormStyle.ink2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 9)
    }
}

/// Erreur sous le champ : rouge, avec icône.
struct EventFormErrorText: View {
    let message: String
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 14, weight: .regular))
                .padding(.top, 1)
            Text(message)
                .font(EventFormStyle.regular(12.5))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundColor(EventFormStyle.errorText)
        .padding(.top, 7)
        .accessibility(label: Text(message))
    }
}

extension View {
    /// Affiche l'erreur d'un champ sous la vue, si elle existe.
    func eventFormError(_ message: String?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            self
            if let message = message {
                EventFormErrorText(message: message)
            }
        }
    }
}

// MARK: - Champ de saisie -

struct EventInputBox<Content: View>: View {
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
        if hasError { return EventFormStyle.errorBorder }
        if isFocused { return EventFormStyle.ink }
        return EventFormStyle.line
    }
}

/// Champ texte sur une ligne (nom, lien de connexion, adresse...).
struct EventFormTextField: View {
    let placeholder: String
    @Binding var text: String
    var hasError = false
    var leadingSystemImage: String? = nil
    var keyboard: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .sentences
    @State private var isFocused = false

    var body: some View {
        EventInputBox(hasError: hasError, isFocused: isFocused) {
            HStack(spacing: 10) {
                if let image = leadingSystemImage {
                    Image(systemName: image)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(EventFormStyle.accent)
                }
                TextField(placeholder, text: $text, onEditingChanged: { editing in
                    isFocused = editing
                })
                .font(EventFormStyle.regular(15.5))
                .foregroundColor(EventFormStyle.ink)
                .keyboardType(keyboard)
                .autocapitalization(autocapitalization)
                .disableAutocorrection(keyboard == .URL)
            }
        }
    }
}

// MARK: - Zone de texte (description) -

struct EventFormTextArea: View {
    let placeholder: String
    @Binding var text: String
    var maxLength: Int
    var hasError = false
    @State private var isFocused = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            EventInputBox(hasError: hasError, isFocused: isFocused, padded: false, minHeight: 112) {
                ZStack(alignment: .topLeading) {
                    EventTextViewRepresentable(text: $text, maxLength: maxLength, onFocusChange: { isFocused = $0 })
                        .frame(height: 112)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                    if text.isEmpty {
                        Text(placeholder)
                            .font(EventFormStyle.regular(15.5))
                            .foregroundColor(EventFormStyle.ink3)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 14)
                            .allowsHitTesting(false)
                    }
                }
            }
            Text("\(text.count) / \(maxLength)")
                .font(EventFormStyle.regular(11))
                .foregroundColor(EventFormStyle.ink3)
        }
    }
}

private struct EventTextViewRepresentable: UIViewRepresentable {
    @Binding var text: String
    let maxLength: Int
    let onFocusChange: (Bool) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.font = ApplicationTheme.getFontNunitoRegular(size: 15.5)
        textView.textColor = EventFormStyle.uiInk
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
        var parent: EventTextViewRepresentable
        init(_ parent: EventTextViewRepresentable) { self.parent = parent }

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

struct EventPickerField: View {
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
        EventInputBox(hasError: hasError, isFocused: isFocused, padded: false) {
            ZStack(alignment: .trailing) {
                EventPickerTextField(
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
                .frame(height: 54)
                Image(systemName: trailingSystemImage)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(EventFormStyle.accent)
                    .padding(.trailing, 14)
                    .allowsHitTesting(false)
            }
        }
    }
}

private final class EventInsetTextField: UITextField {
    var insets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 44)
    override func textRect(forBounds bounds: CGRect) -> CGRect { return bounds.inset(by: insets) }
    override func editingRect(forBounds bounds: CGRect) -> CGRect { return bounds.inset(by: insets) }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect { return bounds.inset(by: insets) }
    override func caretRect(for position: UITextPosition) -> CGRect { return .zero }
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] { return [] }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool { return false }
}

private struct EventPickerTextField: UIViewRepresentable {
    let mode: EventPickerField.Mode
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
        let textField = EventInsetTextField()
        textField.delegate = context.coordinator
        textField.font = ApplicationTheme.getFontNunitoRegular(size: 15.5)
        textField.textColor = EventFormStyle.uiInk
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
            attributes: [.foregroundColor: EventFormStyle.uiInk3, .font: ApplicationTheme.getFontNunitoRegular(size: 15.5)]
        )
        context.coordinator.picker?.minimumDate = minimumDate
        context.coordinator.picker?.maximumDate = maximumDate
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EventPickerTextField
        weak var picker: UIDatePicker?
        weak var textField: UITextField?

        init(_ parent: EventPickerTextField) { self.parent = parent }

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
struct EventSelectableCard: View {
    let symbolNames: [String]
    let title: String
    var subtitle: String? = nil
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(EventFormStyle.accentSoft)
                    Image(systemName: EventFormStyle.symbol(symbolNames))
                        .font(.system(size: 19, weight: .regular))
                        .foregroundColor(EventFormStyle.accent)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(EventFormStyle.bold(14.5))
                        .foregroundColor(EventFormStyle.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(EventFormStyle.regular(12))
                            .foregroundColor(EventFormStyle.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 8)

                ZStack {
                    Circle()
                        .fill(isOn ? EventFormStyle.ink : Color.white)
                    Circle()
                        .stroke(isOn ? EventFormStyle.ink : EventFormStyle.line, lineWidth: 1.8)
                    if isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 24, height: 24)
            }
            .padding(isOn ? 13 : 14)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isOn ? EventFormStyle.ink : EventFormStyle.line, lineWidth: isOn ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(addTraits: isOn ? [.isButton, .isSelected] : [.isButton])
    }
}

struct EventChip: View {
    let title: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(EventFormStyle.semibold(14))
                .foregroundColor(EventFormStyle.ink)
                .padding(.horizontal, isOn ? 14 : 15)
                .padding(.vertical, isOn ? 9 : 10)
                .background(Color.white)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isOn ? EventFormStyle.ink : EventFormStyle.line, lineWidth: isOn ? 2 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(addTraits: isOn ? [.isButton, .isSelected] : [.isButton])
    }
}

struct EventRadioRow: View {
    let title: String
    let isOn: Bool
    let showsSeparator: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack(spacing: 13) {
                    ZStack {
                        Circle().stroke(isOn ? EventFormStyle.ink : EventFormStyle.line, lineWidth: 2)
                        if isOn {
                            Circle().fill(EventFormStyle.ink).frame(width: 11, height: 11)
                        }
                    }
                    .frame(width: 22, height: 22)
                    Text(title)
                        .font(EventFormStyle.regular(15))
                        .foregroundColor(EventFormStyle.ink)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 13)
                .contentShape(Rectangle())
                if showsSeparator {
                    Rectangle().fill(EventFormStyle.line2).frame(height: 1)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(addTraits: isOn ? [.isButton, .isSelected] : [.isButton])
    }
}

/// Mise en page « retour à la ligne » pour les pastilles (compatible iOS 14).
struct EventFlowLayout<Item: Hashable, Content: View>: View {
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

struct EventRemoteImage: UIViewRepresentable {
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
struct EventPhotoImage: View {
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
            EventRemoteImage(urlString: remoteUrl)
        }
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
