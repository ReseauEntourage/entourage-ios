//
//  MJErrorInputTextView.swift
//  entourage
//
//  Created by Jerome on 07/04/2022.
//

import UIKit

@IBDesignable
class MJErrorInputTextView: UIView {
    @IBOutlet var ui_content_view: UIView!
    
    @IBOutlet private weak var ui_title: UILabel!
    @IBOutlet private weak var ui_image: UIImageView!

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialInit()
    }
    
    private func initialInit() {
        Bundle.main.loadNibNamed("MJErrorInputTextView", owner: self)
        addSubview(ui_content_view)
        ui_content_view.frame = self.bounds
        ui_title.font = ApplicationTheme.getFontNunitoLight(size: 11)
        ui_title.textColor = .red
    }
       
    func setupView(title:String? = nil,imageName:String? = nil) {
        ui_title.text = title
        
        if let imageName = imageName {
            ui_image.image = UIImage.init(named: imageName)
        }
    }
}
