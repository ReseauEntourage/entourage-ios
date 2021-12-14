//
//  OTPopInfoCustom.swift
//  entourage
//
//  Created by Jerome.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTPopInfoCustom: UIView {
    
    @IBOutlet weak var ui_popView: UIView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var ui_button_cancel: UIButton!
    @IBOutlet weak var ui_message: UILabel!
    
    @IBOutlet weak var ui_button_validate: UIButton!
    weak var delegate:OTPopInfoDelegate? = nil
    var titleStr = ""
    var messageStr = ""
    var buttonOkStr = ""
    var buttonCancelStr = ""
    
    init(frame: CGRect,delegate:OTPopInfoDelegate,title:String,message:String,buttonOkStr:String,buttonCancelStr:String) {
        super.init(frame: frame)
        setupInitial()
        
        self.titleStr = title
        self.messageStr = message
        self.buttonOkStr = buttonOkStr
        self.buttonCancelStr = buttonCancelStr
        self.delegate = delegate
        
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitial()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupInitial()
    }
    
    func setupInitial() {
        contentView = loadViewFromNib()
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "Pop_Info_Custom", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func setupViews() {
        ui_popView.layer.cornerRadius = 10
        ui_button_validate.layer.cornerRadius = 5
        ui_title.text = titleStr
        ui_message.text = messageStr
        ui_button_validate.setTitle(buttonOkStr.uppercased(), for: .normal)
        ui_button_cancel.setTitle(buttonCancelStr.uppercased(), for: .normal)
    }
    
    @IBAction func action_validate(_ sender: Any) {
        delegate?.validatePop()
    }
    @IBAction func action_close(_ sender: Any) {
        delegate?.closePop()
    }
}


protocol OTPopInfoDelegate : AnyObject {
    func closePop()
    func validatePop()
}
