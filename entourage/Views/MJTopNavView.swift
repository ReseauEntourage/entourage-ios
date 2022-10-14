//
//  MJTopNavView.swift
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
    
    @IBOutlet weak var ui_view_bottom_separator: UIView!
 
    weak var delegate:MJTopNavViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialInit()
    }
    
    private func initialInit() {
        Bundle.main.loadNibNamed("MJTopNavView", owner: self)
        addSubview(ui_content_view)
        ui_content_view.frame = self.bounds
        
        ui_button_back.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }
    
    
    func populateView(title:String,titleFont:UIFont, titleColor:UIColor,delegate:MJTopNavViewDelegate,showSeparator:Bool = true) {
        ui_title.text = title
        ui_title.font = titleFont
        ui_title.textColor = titleColor
        ui_view_bottom_separator.isHidden = !showSeparator
        
        self.delegate = delegate
    }
    
    @objc func goBack() {
        delegate?.goBack()
    }
}

protocol MJTopNavViewDelegate: AnyObject {
    func goBack()
}
