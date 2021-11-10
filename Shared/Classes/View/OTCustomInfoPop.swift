//
//  OTCustomInfoPop.swift
//  entourage
//
//  Created by Jerome on 09/11/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTCustomInfoPop: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var ui_container_view: UIView!
    
    @IBOutlet weak var ui_top_title: UILabel!
    @IBOutlet weak var ui_button: UIButton!
    @IBOutlet weak var ui_title: UILabel!
    
    weak var delegate:ClosePopDelegate?
    
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
        ui_button.setTitle("", for: .normal)
        
        ui_container_view.layer.cornerRadius = 8
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "OTCustomInfoPop", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func setupTitle(title:String,subtitle:String) {
        ui_top_title.text = title
        ui_title.text = subtitle
    }
    
    @IBAction func action_close(_ sender: Any) {
        delegate?.close()
    }
}
