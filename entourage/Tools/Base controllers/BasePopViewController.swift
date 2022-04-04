//
//  BasePopViewController.swift
//  entourage
//
//  Created by Jerome on 04/04/2022.
//

import UIKit

class BasePopViewController: UIViewController {

    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_view_container: UIView!
    @IBOutlet weak var ui_constraint_main_view_top: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        ui_top_view.backgroundColor = .clear
        ui_view_container.backgroundColor = .white
        ui_view_container.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        ui_view_container.layer.maskedCorners = .radiusTopOnly()
        ui_top_view.addTopRadius(cornerRadius: ApplicationTheme.bigCornerRadius)
        
        ui_constraint_main_view_top?.constant = ApplicationTheme.topPopViewControllerSpacing
    }
    
}
