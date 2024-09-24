//
//  LanguageManager.swift
//  entourage
//
//  Created by Clement entourage on 25/10/2023.
//
import Foundation

class LanguageManager {

    private static let selectedLanguageKey = "selected_language"
    
    private static let languageMap: [String: String] = [
        "Français": "fr",
        "English": "en",
        "Deutsch": "de",
        "Español": "es",
        "Polski": "pl",
        "Українська": "uk",
        "Română": "ro",
        "العربية": "ar"
    ]
    
    static func mapLanguageToCode(language: String) -> String {
        return languageMap[language] ?? "fr"  // Default to French if not found
    }

    static func saveLanguageToPreferences(languageCode: String) {
        UserDefaults.standard.setValue(languageCode, forKey: selectedLanguageKey)
    }

    static func loadLanguageFromPreferences() -> String {
        // Defaulting to English ("en") if no language has been selected
        return UserDefaults.standard.string(forKey: selectedLanguageKey) ?? "en"
    }
    static func getTranslatedByDefaultValue() -> Bool {
        if UserDefaults.standard.object(forKey: "isTranslatedByDefault") == nil {
            // Si non, on définit la valeur par défaut à true
            UserDefaults.standard.set(true, forKey: "isTranslatedByDefault")
        }
        // Puis on retourne la valeur
        return UserDefaults.standard.bool(forKey: "isTranslatedByDefault")
    }

    static func setLocale(langCode: String) {
        let locale = Locale(identifier: langCode)
        UserDefaults.standard.set([langCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        Bundle.setLanguage(langCode)
        
        // Définir l'attribut sémantique du contenu en fonction de la direction de la langue
        if Locale.characterDirection(forLanguage: langCode) == .rightToLeft {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        
        // Réinitialiser le contrôleur de vue racine pour appliquer les changements
        if let window = UIApplication.shared.windows.first {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            window.rootViewController = storyboard.instantiateInitialViewController()
            window.makeKeyAndVisible()
        }
    }


    static func getCurrentDeviceLanguage() -> String {
        return Locale.current.languageCode ?? "en"
    }
}

// Helper Extension to override the language in the app
extension Bundle {
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, AnyLanguageBundle.self)
        }
        objc_setAssociatedObject(Bundle.main, &kBundle, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(Bundle.main, &kBundle, Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj")!), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private var kBundle = 0

private class AnyLanguageBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let path = objc_getAssociatedObject(self, &kBundle) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return path.localizedString(forKey: key, value: value, table: tableName)
    }
}
