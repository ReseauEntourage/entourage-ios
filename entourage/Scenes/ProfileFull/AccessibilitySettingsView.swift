//
//  AccessibilitySettingsView.swift
//  entourage
//
//  Feuille « Accessibilité » des paramètres du profil : l'interrupteur « Contraste amélioré ».
//  Affichée seulement quand `AccessibilityModeSettings.isContrastModeAvailable` est vrai (voir ProfileSettingsView).
//

import SwiftUI

struct AccessibilitySettingsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var isHighContrast: Bool
    private let settings: AccessibilityModeSettings?

    init(settings: AccessibilityModeSettings? = AccessibilityModeSettings.forCurrentUser) {
        self.settings = settings
        _isHighContrast = State(initialValue: settings?.isHighContrastEnabled ?? false)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Toggle(isOn: contrastBinding) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("accessibility_contrast_title".localized)
                            .font(Font(UIFont(name: "Quicksand-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)))
                            .foregroundColor(.black)
                        Text("accessibility_contrast_explanation".localized)
                            .font(Font(UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)))
                            .foregroundColor(Color(UIColor.appGris112))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: Color(UIColor.appOrange)))
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Spacer()
            }
            .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all))
            .navigationBarTitle("settings_accessibility_title".localized, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("a11y_close".a11y) { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }

    private var contrastBinding: Binding<Bool> {
        Binding(
            get: { isHighContrast },
            set: { newValue in
                isHighContrast = newValue
                settings?.setHighContrast(newValue)
            }
        )
    }
}
