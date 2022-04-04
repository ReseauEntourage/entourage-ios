//
//  MJNavBackView.swift
//  entourage
//
//  Created by Jerome on 25/03/2022.
//

import UIKit

@IBDesignable
class MJNavBackView: UIView {
    @IBOutlet weak var ui_content_view: UIView!
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_button_back: UIButton!
    
    @IBOutlet weak var ui_image_back: UIImageView!
    @IBOutlet weak var ui_view_bottom_separator: UIView!
    
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
        
        ui_button_back.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }
    
    func populateView(title:String,titleFont:UIFont, titleColor:UIColor,delegate:MJNavBackViewDelegate,showSeparator:Bool = true,backgroundColor:UIColor? = nil,cornerRadius:CGFloat? = nil) {
        ui_title.text = title
        ui_title.font = titleFont
        ui_title.textColor = titleColor
        ui_view_bottom_separator.isHidden = !showSeparator
        
        if let backgroundColor = backgroundColor {
            ui_content_view.backgroundColor = backgroundColor
        }
        
        self.delegate = delegate
        
        
        addTopRadius(cornerRadius: cornerRadius)
    }
    
    func populateCustom(title:String? = nil, titleFont:UIFont? = nil, titleColor:UIColor? = nil, imageName:String?, backgroundColor:UIColor?, delegate:MJNavBackViewDelegate, showSeparator:Bool = true, cornerRadius:CGFloat? = nil) {
        
        if let imageName = imageName {
            ui_image_back.image = UIImage.init(named: imageName)
        }
        if let backgroundColor = backgroundColor {
            ui_content_view.backgroundColor = backgroundColor
        }
        
        ui_title.text = title ?? ""
        if let titleFont = titleFont {
            ui_title.font = titleFont
        }
        if let titleColor = titleColor {
            ui_title.textColor = titleColor
        }
        
        ui_view_bottom_separator.isHidden = !showSeparator
        addTopRadius(cornerRadius: cornerRadius)
        
        self.delegate = delegate
    }
    
    @objc private func goBack() {
        delegate?.goBack()
    }
    
    func addTopRadius(cornerRadius:CGFloat?) {
        guard let cornerRadius = cornerRadius else {
            return
        }
        
        ui_content_view.clipsToBounds = true
        ui_content_view.layer.cornerRadius = cornerRadius
        ui_content_view.layer.maskedCorners = .radiusTopOnly()
    }
}

//MARK: - Protocol -
protocol MJNavBackViewDelegate: AnyObject {
    func goBack()
}
