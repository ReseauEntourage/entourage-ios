//
//  ActionFullTopCell.swift
//  entourage
//
//  Created by Jerome on 05/08/2022.
//

import UIKit
import SDWebImage

class ActionFullTopCell: UITableViewCell {
    
    @IBOutlet weak var ui_view_cancel_opacity: UIView!
    @IBOutlet weak var ui_description: UILabel!
    
    @IBOutlet weak var ui_view_cancel: UIView!
    @IBOutlet weak var ui_title_cancel: UILabel!
    
    @IBOutlet weak var ui_view_contrib: UIView!
    @IBOutlet weak var ui_view_solicitation: UIView!
    
    @IBOutlet weak var ui_img_contrib: UIImageView!
    
    @IBOutlet weak var ui_title_main: UILabel!
    
    @IBOutlet var ui_view_tags: [UIView]!
    @IBOutlet var ui_title_tags: [UILabel]!
    @IBOutlet var ui_img_tags: [UIImageView]!
    
    @IBOutlet weak var ui_view_translate: UIView!
    @IBOutlet weak var ui_label_translate: UILabel!
    
    var action:Action? = nil
    var isTranslated = LanguageManager.getTranslatedByDefaultValue()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_cancel.isHidden = true
        ui_view_contrib.isHidden = true
        ui_view_solicitation.isHidden = true
        
        ui_img_contrib.layer.cornerRadius = 14
        
        ui_view_cancel.layer.cornerRadius = 8
        ui_title_cancel.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldBlanc())
        ui_title_cancel.text = "action_cancel".localized
        
        ui_description.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        for _v in ui_view_tags {
            _v.layer.cornerRadius = _v.frame.height / 2
            _v.layer.borderColor = UIColor.appOrange.cgColor
            _v.layer.borderWidth = 1
        }
        
        for _t in ui_title_tags {
            _t.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoSemiBold(size: 13), color: .appOrange))
        }
        
        ui_title_main.setupFontAndColor(style: MJTextFontColorStyle(font:ApplicationTheme.getFontQuickSandBold(size: 15), color: .black))
    }
    @objc func onTvTranslateClick(){
        isTranslated = !isTranslated
        setTextTranslate()

    }

    func setTextTranslate() {
        // Configurer le UITapGestureRecognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTvTranslateClick))
        ui_label_translate.isUserInteractionEnabled = true
        ui_label_translate.addGestureRecognizer(tapGesture)

        let fullAttributedString = NSMutableAttributedString()

        if isTranslated {
            // Etat 1: "layout_translate_title_translation_title" en normal
            let translatedString = NSLocalizedString("layout_translate_title_translation_title", comment: "")
            fullAttributedString.append(NSAttributedString(string: translatedString))

            // "layout_translate_action_translation_button" en orange et souligné
            let clickHereString = NSLocalizedString("layout_translate_action_translation_button", comment: "")
            let clickHereAttributedString = NSMutableAttributedString(string: " \(clickHereString)")
            clickHereAttributedString.addAttribute(.font, value: UIFont(name: "Quicksand-Bold", size: 13)!, range: NSRange(location: 0, length: clickHereAttributedString.length))
            clickHereAttributedString.addAttribute(.foregroundColor, value: UIColor.orange, range: NSRange(location: 0, length: clickHereAttributedString.length))
            clickHereAttributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: clickHereAttributedString.length))

            fullAttributedString.append(clickHereAttributedString)
        } else {
            // Etat 2: "layout_translate_title_translation_title" = "Some information has been automatically translated."
            let originalString = NSLocalizedString("layout_translate_title_original_title", comment: "")
            fullAttributedString.append(NSAttributedString(string: "\(originalString) "))

            // "layout_translate_title_original_button" en orange et souligné
            let originalButtonString = NSLocalizedString("layout_translate_title_original_button", comment: "")
            let originalButtonAttributedString = NSMutableAttributedString(string: originalButtonString)
            originalButtonAttributedString.addAttribute(.font, value: UIFont(name: "Quicksand-Bold", size: 13)!, range: NSRange(location: 0, length: originalButtonAttributedString.length))
            originalButtonAttributedString.addAttribute(.foregroundColor, value: UIColor.orange, range: NSRange(location: 0, length: originalButtonAttributedString.length))
            originalButtonAttributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: originalButtonAttributedString.length))
            fullAttributedString.append(originalButtonAttributedString)
        }
        // Assigner le texte modifié à un UILabel
        ui_label_translate.attributedText = fullAttributedString
        if(isTranslated){
            if let _title_translation = action?.titleTranslations{
                ui_title_main.text = _title_translation.translation
            }
            if let _desc_translation = action?.descriptionTranslations{
                ui_description.text = _desc_translation.translation
            }
        }else{
            if let _title_translation = action?.titleTranslations{
                ui_title_main.text = _title_translation.original
            }
            if let _desc_translation = action?.descriptionTranslations{
                ui_description.text = _desc_translation.original
            }
        }
    }
    
    func populateCell(action:Action) {
        ui_title_main.text = action.title
        ui_description.text = action.description
        let lang_item = action.descriptionTranslations?.from_lang
        if lang_item == LanguageManager.getCurrentDeviceLanguage() {
            isTranslated = false
            ui_view_translate.setVisibilityGone()
            ui_title_main.text = action.titleTranslations?.original
            ui_description.text = action.descriptionTranslations?.original
        }else{
            isTranslated = true
            ui_title_main.text = action.titleTranslations?.translation
            ui_description.text = action.descriptionTranslations?.translation
        }
        
        self.action = action
        setTextTranslate()
        if action.isCanceled() {
            ui_view_cancel.isHidden = false
            ui_view_cancel_opacity.isHidden = false
        }
        else {
            ui_view_cancel.isHidden = true
            ui_view_cancel_opacity.isHidden = true
        }
        

        if action.isContrib() {
            ui_view_contrib.isHidden = false
            ui_view_solicitation.isHidden = true
            if let imageUrl = action.imageUrl, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
                ui_img_contrib.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
                    if error != nil {
                        self?.ui_img_contrib.image = UIImage.init(named: "ic_placeholder_action")
                    }
                })
            }
            else {
                ui_img_contrib.image = UIImage.init(named: "ic_placeholder_action")
            }
        }
        else {
            ui_view_contrib.isHidden = true
            ui_view_solicitation.isHidden = false
        }
        
        guard let sectionName = action.sectionName else {
            for _t in ui_title_tags {
                _t.text = nil
            }
            for _iv in ui_img_tags {
                _iv.image = nil
            }
            return
        }
        
        for _t in ui_title_tags {
            _t.text = Metadatas.sharedInstance.getTagSectionName(key: sectionName)?.name
        }
        
        for _iv in ui_img_tags {
            if let imgStr = Metadatas.sharedInstance.getTagSectionImageName(key: sectionName) {
                _iv.image = UIImage.init(named: imgStr)
            }
            else {
                _iv.image = nil
            }
        }
    }
}
