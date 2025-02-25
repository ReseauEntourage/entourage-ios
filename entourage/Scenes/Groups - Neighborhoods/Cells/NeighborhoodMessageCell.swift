//
//  NeighborhoodMessageCell.swift
//  entourage
//
//  Created by Jerome on 16/05/2022.
//  Version modifiée pour :
//  - Afficher les liens en bleu si le contenu est du HTML,
//  - Appliquer la police "NunitoSans-Regular" en taille 13,
//  - Supprimer les sauts de ligne/espaces en fin de texte,
//  - Configurer ActiveLabel pour détecter URL et mentions en utilisant une couleur unifiée,
//  - Gérer le tap simple pour ouvrir l’URL extraite (qu'elle soit présente dans le HTML ou en texte brut).
//

import UIKit
import CloudKit
import ActiveLabel

// Définir la couleur bleue unifiée (exemple : system blue)
private let unifiedBlue = UIColor(red: 0.0, green: 122/255.0, blue: 1.0, alpha: 1.0)

// Définir la police de base (au niveau du fichier ou dans la classe)
private let globalBaseFont: UIFont = UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)

class NeighborhoodMessageCell: UITableViewCell {

    @IBOutlet weak var ui_image_user: UIImageView!
    @IBOutlet weak var ui_view_message: UIView!
    @IBOutlet weak var ui_message: ActiveLabel!
    @IBOutlet weak var ui_date: UILabel!
    @IBOutlet weak var ui_username: UILabel!
    
    @IBOutlet weak var ui_bt_signal_me: UIButton?
    @IBOutlet weak var ui_button_signal_other: UIButton?
    
    @IBOutlet weak var ui_lb_error: UILabel!
    @IBOutlet weak var ui_view_error: UIView!
    
    let radius: CGFloat = 22
    
    // Propriétés liées au message
    var messageId: Int = 0
    var messageForRetry = ""
    var positionForRetry = 0
    var userId: Int? = nil
    var innerPostMessage: PostMessage? = nil
    var innerString: String = ""
    
    // Pour les messages supprimés
    var deletedImage: UIImage? = nil
    var deletedImageView: UIImageView? = nil
    
    weak var delegate: MessageCellSignalDelegate? = nil
    
    // Changez "private" en "fileprivate" pour que ce membre soit accessible dans l'extension
    fileprivate static let baseFont: UIFont = UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 28)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_image_user.layer.cornerRadius = ui_image_user.frame.height / 2
        ui_view_message.layer.cornerRadius = radius
        
        ui_message.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_date.setupFontAndColor(style: MJTextFontColorStyle(font: NeighborhoodMessageCell.baseFont, color: .black))
        ui_username.setupFontAndColor(style: MJTextFontColorStyle(font: NeighborhoodMessageCell.baseFont, color: .black))
        
        let alertTheme = MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegularItalic(size: 11), color: .red)
        ui_lb_error?.setupFontAndColor(style: alertTheme)
        ui_lb_error?.text = "neighborhood_error_messageSend".localized
        
        // ActiveLabel : activer la détection d'URL et de mentions
        ui_message.enabledTypes = [.url, .mention]
        ui_message.URLColor = unifiedBlue
        ui_message.mentionColor = unifiedBlue
        ui_message.URLSelectedColor = unifiedBlue
        ui_message.mentionSelectedColor = unifiedBlue
        ui_message.handleURLTap { [weak self] url in
            WebLinkManager.openUrl(url: url,
                                   openInApp: true,
                                   presenterViewController: AppState.getTopViewController())
        }
        ui_message.handleMentionTap { mention in
            // Action sur la mention, par exemple :
            print("Tap mention: \(mention)")
        }
        
        // Ajouter un tap gesture pour gérer le clic sur le label (pour extraire l'URL)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnMessage(_:)))
        ui_message.isUserInteractionEnabled = true
        ui_message.addGestureRecognizer(tapGesture)
        
        ui_message.enableLongPressCopy()
        
        deletedImage = UIImage(named: "ic_deleted_comment")
        deletedImageView = UIImageView(image: deletedImage)
        deletedImageView?.frame = CGRect(x: 16, y: 16, width: 15, height: 15)
        deletedImageView?.tintColor = UIColor.gray
    }
    
    @objc func handleTapOnMessage(_ sender: UITapGestureRecognizer) {
        guard let html = innerPostMessage?.contentHtml, !html.isEmpty else { return }
        
        // Première tentative : extraction via balise <a href="...">
        if let url = extractUrl(from: html) {
            WebLinkManager.openUrl(url: url,
                                   openInApp: true,
                                   presenterViewController: AppState.getTopViewController())
            return
        }
        
        // Deuxième tentative : si le texte est un lien brut
        let trimmedText = html.trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = URL(string: trimmedText), UIApplication.shared.canOpenURL(url) {
            WebLinkManager.openUrl(url: url,
                                   openInApp: true,
                                   presenterViewController: AppState.getTopViewController())
        }
    }
    
    @objc func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began,
           let userId = userId,
           let innerPostMessage = innerPostMessage {
            delegate?.signalMessage(messageId: messageId,
                                    userId: userId,
                                    textString: innerPostMessage.content ?? "")
        }
    }
    
    // MARK: - Populate Cell (Messages classiques de groupe)
    func populateCell(isMe: Bool,
                      message: PostMessage,
                      isRetry: Bool,
                      positionRetry: Int = 0,
                      delegate: MessageCellSignalDelegate,
                      isTranslated: Bool) {
        
        innerPostMessage = message
        messageId = message.uid
        userId = message.user?.sid
        
        self.delegate = delegate
        self.messageForRetry = message.content ?? ""
        self.positionForRetry = positionRetry
        
        if isMe {
            ui_bt_signal_me?.isHidden = true
            ui_view_message.backgroundColor = .appOrangeLight_50
            ui_date.textColor = .appOrangeLight
            ui_username.textColor = .appOrangeLight
        } else {
            ui_view_message.backgroundColor = .appBeige
            ui_date.textColor = .black
            ui_username.textColor = .black
        }
        
        if let avatarURL = message.user?.avatarURL, let url = URL(string: avatarURL) {
            ui_image_user.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder_user"))
        } else {
            ui_image_user.image = UIImage(named: "placeholder_user")
        }
        
        // Gestion retry
        if isRetry {
            ui_view_error?.isHidden = false
            ui_username.text = ""
            ui_date.text = ""
        } else {
            ui_view_error?.isHidden = true
            ui_date.text = "le \(message.createdDateTimeFormatted)"
            ui_username.text = isMe ? "" : message.user?.displayName
        }
        
        // Gestion status
        if let status = message.status {
            if status == "deleted" {
                let padding = NSAttributedString(string: "  ") // 3 espaces pour du padding
                let messageText = NSAttributedString(string: "deleted_comment".localized, attributes: [
                    .foregroundColor: UIColor.appGreyTextDeleted
                ])

                let finalText = NSMutableAttributedString()
                finalText.append(padding) // Ajoute du padding gauche
                finalText.append(messageText) // Ajoute le vrai message
                ui_message.attributedText = finalText
                ui_view_message.backgroundColor = UIColor.appGreyCellDeleted
                if let deletedImageView = deletedImageView,
                   !(ui_message.superview?.subviews.contains(deletedImageView) ?? false) {
                    ui_message.superview?.addSubview(deletedImageView)
                    
                }
            }
            else if status == "offensive" || status == "offensible" {
                let padding = NSAttributedString(string: "        ") // 3 espaces pour du padding
                let messageText = NSAttributedString(string: "content_removed".localized, attributes: [
                    .foregroundColor: UIColor.appGreyTextDeleted
                ])

                let finalText = NSMutableAttributedString()
                finalText.append(padding) // Ajoute du padding gauche
                finalText.append(messageText) // Ajoute le vrai message

                ui_message.attributedText = finalText
                
                ui_view_message.backgroundColor = UIColor.appGreyCellDeleted
                if let deletedImageView = deletedImageView,
                   !(ui_message.superview?.subviews.contains(deletedImageView) ?? false) {
                    ui_message.superview?.addSubview(deletedImageView)
                }
            }
            else {
                // Message “normal”
                if let deletedImageView = deletedImageView,
                   ui_message.superview?.subviews.contains(deletedImageView) == true {
                    deletedImageView.removeFromSuperview()
                }
                // Geste pour signaler (long press)
                if isMe {
                    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
                    ui_message.addGestureRecognizer(longPressGesture)
                }
                ui_message.attributedText = getAttributedDisplayText(for: message, isTranslated: isTranslated)
                ui_view_message.backgroundColor = isMe ? UIColor.appOrangeLight_50 : UIColor.appBeige
            }
        } else {
            // Pas de status => message “normal”
            ui_message.attributedText = getAttributedDisplayText(for: message, isTranslated: isTranslated)
            ui_message.textColor = UIColor.black
        }
        ui_message.setFontBody(size: 13)
        layoutIfNeeded()
    }
    
    // MARK: - Populate Cell (Messages conversation One2One)
    func populateCellConversation(isMe: Bool,
                                  message: PostMessage,
                                  isRetry: Bool,
                                  positionRetry: Int = 0,
                                  isOne2One: Bool,
                                  delegate: MessageCellSignalDelegate) {
        
        self.innerPostMessage = message
        messageId = message.uid
        userId = message.user?.sid
        
        ui_bt_signal_me?.isHidden = true
        ui_button_signal_other?.isHidden = true
        ui_bt_signal_me?.addTarget(self, action: #selector(action_signal_conversation), for: .touchUpInside)
        ui_button_signal_other?.addTarget(self, action: #selector(action_signal_conversation), for: .touchUpInside)
        
        self.delegate = delegate
        self.messageForRetry = message.content ?? ""
        self.positionForRetry = positionRetry
        
        // Couleurs (on peut ajuster si besoin)
        ui_date.textColor = .appOrangeLight
        ui_username.textColor = .appOrangeLight
        ui_view_message.backgroundColor = isMe ? .appOrangeLight_50 : .appBeige
        
        // Avatar
        if let avatarURL = message.user?.avatarURL, let url = URL(string: avatarURL) {
            ui_image_user.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder_user"))
        } else {
            ui_image_user.image = UIImage(named: "placeholder_user")
        }
        
        // Gestion status
        if let status = message.status {
            if status == "deleted" {
                ui_message.text = "deleted_message".localized
                let padding = NSAttributedString(string: "   ") // 3 espaces pour du padding
                let messageText = NSAttributedString(string: "deleted_comment".localized, attributes: [
                    .foregroundColor: UIColor.appGreyTextDeleted
                ])

                let finalText = NSMutableAttributedString()
                finalText.append(padding) // Ajoute du padding gauche
                finalText.append(messageText) // Ajoute le vrai message
                ui_message.attributedText = finalText
                ui_view_message.backgroundColor = UIColor.appGreyCellDeleted
                if let deletedImageView = deletedImageView,
                   !(ui_message.superview?.subviews.contains(deletedImageView) ?? false) {
                    ui_message.superview?.addSubview(deletedImageView)
                }
            }
            else if status == "offensive" || status == "offensible" {
                let padding = NSAttributedString(string: "        ") // 3 espaces pour du padding
                let messageText = NSAttributedString(string: "content_removed".localized, attributes: [
                    .foregroundColor: UIColor.appGreyTextDeleted
                ])

                let finalText = NSMutableAttributedString()
                finalText.append(padding) // Ajoute du padding gauche
                finalText.append(messageText) // Ajoute le vrai message

                ui_message.attributedText = finalText
                ui_view_message.backgroundColor = UIColor.appGreyCellDeleted
                if let deletedImageView = deletedImageView,
                   !(ui_message.superview?.subviews.contains(deletedImageView) ?? false) {
                    ui_message.superview?.addSubview(deletedImageView)
                }
            }
            else {
                // Message “normal” dans la conversation
                if let deletedImageView = deletedImageView,
                   ui_message.superview?.subviews.contains(deletedImageView) == true {
                    deletedImageView.removeFromSuperview()
                }
                
                // S’il s’agit du message de l’utilisateur courant, on peut ajouter un Long Press
                // pour le signalement par ex.
                if isMe {
                    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
                    ui_message.addGestureRecognizer(longPressGesture)
                }
                
                // ICI => on remplace le simple "ui_message.text = content" par la logique d'attribution HTML
                // On ne gère pas forcément la traduction dans one2one => on met isTranslated: false,
                // ou on ajoute un param si nécessaire.
                ui_message.attributedText = getAttributedDisplayText(for: message, isTranslated: false)
                
                // Couleur d’arrière-plan
                ui_view_message.backgroundColor = isMe ? UIColor.appOrangeLight_50 : UIColor.appBeige
                ui_message.textColor = UIColor.black
            }
        }
        else {
            // Pas de status => message “normal”
            ui_message.attributedText = getAttributedDisplayText(for: message, isTranslated: false)
            ui_message.textColor = UIColor.black
        }
        
        // Gestion Retry
        if isRetry {
            ui_view_error?.isHidden = false
            ui_username.text = ""
            ui_date.text = ""
        } else {
            ui_view_error?.isHidden = true
            if isOne2One {
                ui_date.text = "\(message.createdTimeFormatted)"
                ui_username.text = message.user?.displayName ?? ""
            } else {
                if isMe {
                    ui_date.text = "\(message.createdTimeFormatted)"
                    ui_username.text = ""
                } else {
                    ui_date.text = " à \(message.createdTimeFormatted)"
                    ui_username.text = message.user?.displayName ?? "- !"
                }
            }
        }
        ui_message.setFontBody(size: 13)
        layoutIfNeeded()
    }
    
    @objc func action_signal_conversation() {
        if let userId = userId,
           let innerPostMessage = innerPostMessage {
            delegate?.signalMessage(messageId: messageId,
                                    userId: userId,
                                    textString: innerPostMessage.content ?? "")
        }
    }
    
    @IBAction func action_signal_message(_ sender: Any) {
        if let userId = userId,
           let innerPostMessage = innerPostMessage {
            delegate?.signalMessage(messageId: messageId,
                                    userId: userId,
                                    textString: innerPostMessage.content ?? "")
        }
    }
    
    @IBAction func action_retry(_ sender: Any) {
        delegate?.retrySend(message: messageForRetry, positionForRetry: positionForRetry)
    }
    
    @IBAction func action_show_user(_ sender: Any) {
        Logger.print("***** action show : \(String(describing: userId))")
        delegate?.showUser(userId: userId)
    }
}

// MARK: - Extension avec les fonctions d’aide
extension NeighborhoodMessageCell {
    
    /// Construit un NSAttributedString à partir d'une chaîne HTML + police de base.
    private func attributedString(fromHTML html: String, withBaseFont font: UIFont) -> NSAttributedString {
        guard let data = html.data(using: .utf8) else {
            return NSAttributedString(string: html, attributes: [.font: font])
        }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        do {
            let attrString = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
            let fullRange = NSRange(location: 0, length: attrString.length)
            
            // Applique la police de base sur l'ensemble du texte
            attrString.addAttribute(.font, value: font, range: fullRange)
            
            // Parcourt les attributs .link pour ajuster la couleur + soulignement
            attrString.enumerateAttribute(.link, in: fullRange, options: []) { (value, range, _) in
                guard range.location != NSNotFound, range.location + range.length <= attrString.length else { return }
                if value != nil {
                    attrString.addAttribute(.foregroundColor, value: unifiedBlue, range: range)
                    attrString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                } else {
                    attrString.addAttribute(.foregroundColor, value: UIColor.black, range: range)
                }
            }
            
            // Supprime les sauts de ligne ou espaces de fin
            while attrString.string.hasSuffix("\n") || attrString.string.hasSuffix(" ") {
                attrString.deleteCharacters(in: NSRange(location: attrString.length - 1, length: 1))
            }
            return attrString
        } catch {
            return NSAttributedString(string: html, attributes: [.font: font, .foregroundColor: UIColor.black])
        }
    }
    
    /// Construit un NSAttributedString « brut » à partir de texte simple.
    private func plainAttributedString(from text: String, withBaseFont font: UIFont) -> NSAttributedString {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return NSAttributedString(string: trimmed, attributes: [.font: font, .foregroundColor: UIColor.black])
    }
    
    /// Essaie d'extraire une URL (dans un <a href=...> ou brute) depuis une chaîne HTML
    private func extractUrl(from input: String) -> URL? {
        // 1️⃣ Vérifie d'abord s'il y a une URL dans une balise <a>
        let linkPattern = "<a\\s+(?:[^>]*?\\s+)?href=[\"']([^\"']+)[\"']"
        if let linkUrl = extractFirstMatch(from: input, using: linkPattern) {
            return URL(string: linkUrl)
        }
        
        // 2️⃣ Si aucune balise <a>, cherche une URL brute dans le texte
        let urlPattern = #"(https?:\/\/[^\s\"'<>]+)"#
        if let foundUrl = extractFirstMatch(from: input, using: urlPattern) {
            return URL(string: foundUrl)
        }
        
        return nil
    }

    /// Utilitaire pour extraire la première capture d'une regex
    private func extractFirstMatch(from input: String, using pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        
        let nsString = input as NSString
        if let match = regex.firstMatch(in: input, options: [], range: NSRange(location: 0, length: nsString.length)) {
            return nsString.substring(with: match.range(at: 1))
        }
        
        return nil
    }
    
    /// Récupère l'AttributedString final (HTML ou texte simple), en tenant compte d'une éventuelle traduction.
    private func getAttributedDisplayText(for message: PostMessage, isTranslated: Bool) -> NSAttributedString {
        // 1) Si le message est marqué "traduit"
        if isTranslated {
            // Priorité au HTML traduit
            if let translationsHtml = message.contentTranslationsHtml {
                if let translationHtml = translationsHtml.translation, !translationHtml.isEmpty {
                    return attributedString(fromHTML: translationHtml, withBaseFont: NeighborhoodMessageCell.baseFont)
                }
                if let originalHtml = translationsHtml.original, !originalHtml.isEmpty {
                    return attributedString(fromHTML: originalHtml, withBaseFont: NeighborhoodMessageCell.baseFont)
                }
            }
            // Sinon on regarde la traduction "texte brut"
            if let translations = message.contentTranslations {
                if let translation = translations.translation, !translation.isEmpty {
                    return plainAttributedString(from: translation, withBaseFont: NeighborhoodMessageCell.baseFont)
                }
                if let original = translations.original, !original.isEmpty {
                    return plainAttributedString(from: original, withBaseFont: NeighborhoodMessageCell.baseFont)
                }
            }
        }
        else {
            // 2) Pas de traduction => affiche le contentHtml, sinon le content
            if let contentHtml = message.contentHtml, !contentHtml.isEmpty {
                return attributedString(fromHTML: contentHtml, withBaseFont: NeighborhoodMessageCell.baseFont)
            }
            if let content = message.content, !content.isEmpty {
                return plainAttributedString(from: content, withBaseFont: NeighborhoodMessageCell.baseFont)
            }
        }
        
        var _message = message.contentHtml
        if _message == "" || _message ==  nil {
            _message = message.content
        }
        // 3) Par défaut, si rien n'est dispo
        return attributedString(fromHTML: _message ?? "Erreur de chargement", withBaseFont: NeighborhoodMessageCell.baseFont)
    }
}

// MARK: - Protocole de délégation pour la cellule
protocol MessageCellSignalDelegate: AnyObject {
    func signalMessage(messageId: Int, userId: Int, textString: String)
    func retrySend(message: String, positionForRetry: Int)
    func showUser(userId: Int?)
    func showWebUrl(url: URL)
}
