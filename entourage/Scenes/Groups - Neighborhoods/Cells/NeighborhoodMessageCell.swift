//
//  NeighborhoodMessageCell.swift
//  entourage
//
//  Created by Jerome on 16/05/2022.
//  Version modifiée pour afficher les liens en bleu si le contenu est du HTML
//  et appliquer la police "NunitoSans-Regular" en taille 13
//

import UIKit
import CloudKit
import ActiveLabel

// Définir la police de base
private let baseFont: UIFont = UIFont(name: "NunitoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)

// Fonction pour convertir une chaîne HTML en NSAttributedString en appliquant la police de base
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
        // Appliquer la police de base sur l'ensemble du texte
        attrString.addAttribute(.font, value: font, range: fullRange)
        // Mettre en forme les liens : couleur bleue et soulignement
        attrString.enumerateAttribute(.link, in: fullRange, options: []) { (value, range, _) in
            if value != nil {
                attrString.addAttribute(.foregroundColor, value: UIColor.blue, range: range)
                attrString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            } else {
                attrString.addAttribute(.foregroundColor, value: UIColor.black, range: range)
            }
        }
        return attrString
    } catch {
        return NSAttributedString(string: html, attributes: [.font: font, .foregroundColor: UIColor.black])
    }
}

// Fonction utilitaire pour créer un NSAttributedString à partir d'un texte non-HTML en appliquant la police de base
private func plainAttributedString(from text: String, withBaseFont font: UIFont) -> NSAttributedString {
    return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: UIColor.black])
}

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
    var messageId: Int = 0
    var messageForRetry = ""
    var positionForRetry = 0
    var userId: Int? = nil
    var deletedImage: UIImage? = nil
    var deletedImageView: UIImageView? = nil
    var innerPostMessage: PostMessage? = nil
    var innerString: String = ""
    
    weak var delegate: MessageCellSignalDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_image_user.layer.cornerRadius = ui_image_user.frame.height / 2
        ui_view_message.layer.cornerRadius = radius
        // Ces configurations de font peuvent être redéfinies par l'attributedText
        ui_message.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_date.setupFontAndColor(style: MJTextFontColorStyle(font: baseFont, color: .black))
        ui_username.setupFontAndColor(style: MJTextFontColorStyle(font: baseFont, color: .black))
        
        let alertTheme = MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegularItalic(size: 11), color: .red)
        ui_lb_error?.setupFontAndColor(style: alertTheme)
        ui_lb_error?.text = "neighborhood_error_messageSend".localized
        
        // On désactive l'interaction d'ActiveLabel pour ce cas précis
        ui_message.enableLongPressCopy()
        
        deletedImage = UIImage(named: "ic_deleted_comment")
        deletedImageView = UIImageView(image: deletedImage)
        deletedImageView?.frame = CGRect(x: 16, y: 16, width: 15, height: 15)
        deletedImageView?.tintColor = UIColor.gray
    }
    
    @objc func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began, let userId = userId, let innerPostMessage = innerPostMessage {
            delegate?.signalMessage(messageId: messageId, userId: userId, textString: innerPostMessage.content ?? "")
        }
    }
    
    /// Retourne un NSAttributedString à afficher en fonction des données disponibles.
    /// Si isTranslated est vrai, on privilégie le contenu HTML de la traduction (contentTranslationsHtml) puis le plain text,
    /// sinon on utilise d'abord contentHtml, puis content.
    private func getAttributedDisplayText(for message: PostMessage, isTranslated: Bool) -> NSAttributedString {
        if isTranslated {
            if let translationsHtml = message.contentTranslationsHtml {
                if let translationHtml = translationsHtml.translation, !translationHtml.isEmpty {
                    return attributedString(fromHTML: translationHtml, withBaseFont: baseFont)
                }
                if let originalHtml = translationsHtml.original, !originalHtml.isEmpty {
                    return attributedString(fromHTML: originalHtml, withBaseFont: baseFont)
                }
            }
            if let translations = message.contentTranslations {
                if let translation = translations.translation, !translation.isEmpty {
                    return plainAttributedString(from: translation, withBaseFont: baseFont)
                }
                if let original = translations.original, !original.isEmpty {
                    return plainAttributedString(from: original, withBaseFont: baseFont)
                }
            }
        } else {
            if let contentHtml = message.contentHtml, !contentHtml.isEmpty {
                return attributedString(fromHTML: contentHtml, withBaseFont: baseFont)
            }
            if let content = message.content, !content.isEmpty {
                return plainAttributedString(from: content, withBaseFont: baseFont)
            }
        }
        return NSAttributedString(string: "", attributes: [.font: baseFont])
    }
    
    /// Configure la cellule pour une discussion (chat) en utilisant le contenu approprié (HTML ou plain text)
    func populateCell(isMe: Bool, message: PostMessage, isRetry: Bool, positionRetry: Int = 0, delegate: MessageCellSignalDelegate, isTranslated: Bool) {
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
        
        if isRetry {
            ui_view_error?.isHidden = false
            ui_username.text = ""
            ui_date.text = ""
        } else {
            ui_view_error?.isHidden = true
            ui_date.text = "le \(message.createdDateTimeFormatted)"
            ui_username.text = isMe ? "" : message.user?.displayName
        }
        
        if let status = message.status {
            if status == "deleted" {
                ui_message.text = "deleted_comment".localized
                ui_message.textColor = UIColor.appGreyTextDeleted
                ui_view_message.backgroundColor = UIColor.appGreyCellDeleted
                if let deletedImageView = deletedImageView,
                   !(ui_message.superview?.subviews.contains(deletedImageView) ?? false) {
                    ui_message.superview?.addSubview(deletedImageView)
                }
            } else if status == "offensive" || status == "offensible" {
                ui_message.text = "content_removed".localized
                ui_message.textColor = UIColor.appGreyTextDeleted
                ui_view_message.backgroundColor = UIColor.appGreyCellDeleted
                if let deletedImageView = deletedImageView,
                   !(ui_message.superview?.subviews.contains(deletedImageView) ?? false) {
                    ui_message.superview?.addSubview(deletedImageView)
                }
            } else {
                if let deletedImageView = deletedImageView,
                   ui_message.superview?.subviews.contains(deletedImageView) == true {
                    deletedImageView.removeFromSuperview()
                }
                if isMe {
                    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
                    ui_message.addGestureRecognizer(longPressGesture)
                }
                // Afficher le contenu avec NSAttributedString en conservant la police
                ui_message.attributedText = getAttributedDisplayText(for: message, isTranslated: isTranslated)
                ui_view_message.backgroundColor = isMe ? UIColor.appOrangeLight_50 : UIColor.appBeige
            }
        } else {
            ui_message.attributedText = getAttributedDisplayText(for: message, isTranslated: isTranslated)
            ui_message.textColor = UIColor.black
        }
        
        layoutIfNeeded()
    }
    
    /// Configure la cellule pour une conversation (one-to-one ou groupe)
    func populateCellConversation(isMe: Bool, message: PostMessage, isRetry: Bool, positionRetry: Int = 0, isOne2One: Bool, delegate: MessageCellSignalDelegate) {
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
        
        ui_date.textColor = .appOrangeLight
        ui_username.textColor = .appOrangeLight
        
        ui_view_message.backgroundColor = isMe ? .appOrangeLight_50 : .appBeige
        
        if let avatarURL = message.user?.avatarURL, let url = URL(string: avatarURL) {
            ui_image_user.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder_user"))
        } else {
            ui_image_user.image = UIImage(named: "placeholder_user")
        }
        
        if let status = message.status {
            if status == "deleted" {
                ui_message.text = "deleted_message".localized
                ui_message.textColor = UIColor.appGreyTextDeleted
                ui_view_message.backgroundColor = UIColor.appGreyCellDeleted
                if let deletedImageView = deletedImageView,
                   !(ui_message.superview?.subviews.contains(deletedImageView) ?? false) {
                    ui_message.superview?.addSubview(deletedImageView)
                }
            } else if status == "offensive" || status == "offensible" {
                ui_message.text = "content_removed".localized
                ui_message.textColor = UIColor.appGreyTextDeleted
                ui_view_message.backgroundColor = UIColor.appGreyCellDeleted
                if let deletedImageView = deletedImageView,
                   !(ui_message.superview?.subviews.contains(deletedImageView) ?? false) {
                    ui_message.superview?.addSubview(deletedImageView)
                }
            } else {
                if let deletedImageView = deletedImageView,
                   ui_message.superview?.subviews.contains(deletedImageView) == true {
                    deletedImageView.removeFromSuperview()
                }
                if isMe {
                    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
                    ui_message.addGestureRecognizer(longPressGesture)
                    ui_message.text = message.content ?? ""
                    ui_message.textColor = UIColor.black
                    ui_view_message.backgroundColor = UIColor.appOrangeLight_50
                } else {
                    ui_message.text = message.content ?? ""
                    ui_message.textColor = UIColor.black
                    ui_view_message.backgroundColor = UIColor.appBeige
                }
            }
        }
        
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
        
        layoutIfNeeded()
    }
    
    @objc func action_signal_conversation() {
        if let userId = userId, let innerPostMessage = innerPostMessage {
            delegate?.signalMessage(messageId: messageId, userId: userId, textString: innerPostMessage.content ?? "")
        }
    }
    
    @IBAction func action_signal_message(_ sender: Any) {
        if let userId = userId, let innerPostMessage = innerPostMessage {
            delegate?.signalMessage(messageId: messageId, userId: userId, textString: innerPostMessage.content ?? "")
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

protocol MessageCellSignalDelegate: AnyObject {
    func signalMessage(messageId: Int, userId: Int, textString: String)
    func retrySend(message: String, positionForRetry: Int)
    func showUser(userId: Int?)
    func showWebUrl(url: URL)
}
