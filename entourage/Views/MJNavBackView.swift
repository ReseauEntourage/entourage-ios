//
//  MJNavBackView.swift
//  entourage
//
//  Created by Jerome on 25/03/2022.
//

import UIKit

@IBDesignable
class MJNavBackView: UIView {
    @IBOutlet private weak var ui_view_back: UIView!
    @IBOutlet private weak var ui_view_close: UIView!
    
    @IBOutlet weak var ui_view_back_with_subtitle: UIView!
    @IBOutlet private weak var ui_content_view: UIView!
    
    @IBOutlet weak var ui_subtitle: UILabel!
    @IBOutlet private var ui_titles: [UILabel]!
    @IBOutlet private var ui_views_bottom_separator: [UIView]!
    
    @IBOutlet private var ui_buttons_close: [UIButton]!
    @IBOutlet private weak var ui_image_back: UIImageView!
    @IBOutlet private weak var ui_image_back_sub: UIImageView!
    
    @IBOutlet private weak var ui_image_close: UIImageView!
    
    @IBOutlet private weak var ui_constraint_left_button_back: NSLayoutConstraint!
    @IBOutlet private weak var ui_constraint_left_button_back_sub: NSLayoutConstraint!
    
    @IBOutlet weak var ui_view_event: UIView!
    @IBOutlet weak var iv_event: UIImageView!
    @IBOutlet weak var ui_label_title_event: UILabel!
    @IBOutlet weak var ui_label_event_date: UILabel!
    
    @IBOutlet var ui_constraint_title_right_margins: [NSLayoutConstraint]!
    
    weak var delegate:MJNavBackViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialInit()
    }
    
    private func initialInit() {
        Bundle.main.loadNibNamed("MJNavBackView", owner: self)
        addSubview(ui_content_view)
        ui_content_view.frame = self.bounds
        
        for button in ui_buttons_close {
            button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        }
        ui_view_close.isHidden = true
        ui_view_back_with_subtitle.isHidden = true
        ui_subtitle.setupFontAndColor(style: ApplicationTheme.getFontCourantItalicNoir(size: 15))
    }
    
    func setTitlesOneLine(){
        for _uititle in ui_titles {
            _uititle.numberOfLines = 1
        }
    }
    
    func updateTitle(title:String) {
        for _uititle in ui_titles {
            _uititle.text = title
        }
    }
    
    
    
    func hideButtonBackForUnboarding(hide:Bool) {
        ui_view_close.isHidden = !hide
        ui_view_back.isHidden = hide
        ui_image_close.isHidden = hide
        for button in ui_buttons_close {
            button.isHidden = hide
        }
    }
    
    func formatEventDate(_ isoDate: String?) -> String {
        guard let isoDate = isoDate else { return "" }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR") // Français
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX" // Format correspondant à ta date exacte

        if let date = formatter.date(from: isoDate) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "EEEE d MMMM yyyy"
            displayFormatter.locale = Locale(identifier: "fr_FR") // Assurer le bon format français
            return displayFormatter.string(from: date)
        }
        
        return "Date invalide"
    }

    
    func populateView(title:String,titleFont:UIFont, titleColor:UIColor,delegate:MJNavBackViewDelegate,showSeparator:Bool = true,backgroundColor:UIColor? = nil,cornerRadius:CGFloat? = nil, isClose:Bool = false, doubleRightMargin:Bool = false, event:Event? = nil) {
        self.ui_label_title_event.setFontTitle(size: 15)
        self.ui_label_event_date.setFontBody(size: 13)
        self.semanticContentAttribute = .unspecified // ou .forceRightToLeft si nécessaire
        self.populateCustom(title: title, titleFont: titleFont, titleColor: titleColor, imageName: nil, backgroundColor: backgroundColor, delegate: delegate, showSeparator: showSeparator, cornerRadius: cornerRadius, isClose: isClose,doubleRightMargin: doubleRightMargin)
        if event == nil {
            ui_view_event.isHidden = true
        }else {
            ui_view_event.isHidden = false
            ui_label_title_event.text = event?.title
            ui_label_event_date.text = formatEventDate(event?.metadata?.starts_at).capitalizingFirstLetter()
            if let _url = URL(string: event?.metadata?.portrait_url ?? "") {
                iv_event.sd_setImage(with: _url, placeholderImage: UIImage.init(named: "ic_placeholder_my_event"))
                iv_event.layer.cornerRadius = 5
            }
        }
        let tapEventGesture = UITapGestureRecognizer(target: self, action: #selector(eventTapped))
        ui_view_event.addGestureRecognizer(tapEventGesture)
        ui_view_event.isUserInteractionEnabled = true

    }
    
    @objc private func eventTapped() {
        delegate?.didTapEvent()
    }
    
    func populateCustom(title:String? = nil, titleFont:UIFont? = nil, titleColor:UIColor? = nil, imageName:String?, backgroundColor:UIColor?, delegate:MJNavBackViewDelegate, showSeparator:Bool = true, cornerRadius:CGFloat? = nil, isClose:Bool = false, marginLeftButton:CGFloat? = nil, subtitle:String? = nil, doubleRightMargin:Bool = false) {
        self.semanticContentAttribute = .unspecified // ou .forceRightToLeft si nécessaire
        if doubleRightMargin {
            for _constraint in ui_constraint_title_right_margins {
                _constraint.constant = _constraint.constant * 2
            }
        }
        
        
        ui_view_close.isHidden = !isClose
        ui_view_back.isHidden = isClose
        
        if let subtitle = subtitle {
            ui_view_close.isHidden = true
            ui_view_back.isHidden = true
            ui_view_back_with_subtitle.isHidden = false
            ui_subtitle.text = subtitle
        }
        else {
            ui_view_back_with_subtitle.isHidden = true
        }
        
        if let imageName = imageName {
            ui_image_back.image = UIImage.init(named: imageName)
            ui_image_back_sub.image = UIImage.init(named: imageName)
        }
        
        if let backgroundColor = backgroundColor {
            ui_content_view.backgroundColor = backgroundColor
        }
        
        for _uititle in ui_titles {
            _uititle.text = title ?? ""
            if let titleFont = titleFont {
                _uititle.font = titleFont
            }
            if let titleColor = titleColor {
                _uititle.textColor = titleColor
            }
        }
        
        for _view in ui_views_bottom_separator {
            _view.isHidden = !showSeparator
        }
        
        addTopRadius(cornerRadius: cornerRadius)
        
        self.delegate = delegate
        
        if let marginLeftButton = marginLeftButton {
            self.ui_constraint_left_button_back.constant = marginLeftButton
            self.ui_constraint_left_button_back_sub.constant = marginLeftButton
        }
    }
    
    func changeTitleColor(titleColor:UIColor) {
        for _uititle in ui_titles {
            _uititle.textColor = titleColor
        }
    }
    
    @objc private func goBack() {
        delegate?.goBack()
    }
    
    func addTopRadius(cornerRadius:CGFloat?) {
        guard let cornerRadius = cornerRadius else {
            return
        }
        
        ui_content_view.clipsToBounds = true
        ui_content_view.addRadiusTopOnly(radius: cornerRadius)
    }
}

//MARK: - Protocol -
protocol MJNavBackViewDelegate: AnyObject {
    func goBack()
    func didTapEvent()

}
