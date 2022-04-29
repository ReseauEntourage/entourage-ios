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
    
    @IBOutlet private weak var ui_content_view: UIView!
    
    @IBOutlet private var ui_titles: [UILabel]!
    @IBOutlet private var ui_views_bottom_separator: [UIView]!
    
    @IBOutlet private var ui_buttons_close: [UIButton]!
    @IBOutlet private weak var ui_image_back: UIImageView!
    
    @IBOutlet private weak var ui_image_close: UIImageView!
    
    @IBOutlet private weak var ui_constraint_left_button_back: NSLayoutConstraint!
    
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
    }
    
    func populateView(title:String,titleFont:UIFont, titleColor:UIColor,delegate:MJNavBackViewDelegate,showSeparator:Bool = true,backgroundColor:UIColor? = nil,cornerRadius:CGFloat? = nil, isClose:Bool = false) {
             
        self.populateCustom(title: title, titleFont: titleFont, titleColor: titleColor, imageName: nil, backgroundColor: backgroundColor, delegate: delegate, showSeparator: showSeparator, cornerRadius: cornerRadius, isClose: isClose)
    }
    
    func populateCustom(title:String? = nil, titleFont:UIFont? = nil, titleColor:UIColor? = nil, imageName:String?, backgroundColor:UIColor?, delegate:MJNavBackViewDelegate, showSeparator:Bool = true, cornerRadius:CGFloat? = nil, isClose:Bool = false, marginLeftButton:CGFloat? = nil) {
        
        ui_view_close.isHidden = !isClose
        ui_view_back.isHidden = isClose
        
        if let imageName = imageName {
            ui_image_back.image = UIImage.init(named: imageName)
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
}
