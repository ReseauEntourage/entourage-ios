//
//  BaseFullScreenNavViewController.swift
//  entourage
//
//  Created by Jerome on 04/04/2022.
//

import UIKit

class BaseFullScreenNavViewController: UINavigationController {
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            isModalInPresentation = false
        }
    }
}
