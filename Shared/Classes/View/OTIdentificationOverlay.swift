//
//  OTIdentificationOverlayView.swift
//  entourage
//
//  Created by Moulinet Chloë on 19/10/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import UIKit

class OTIdentificationOverlayView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBAction func signUpActionButton(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "mainStoryboard", bundle: nil)
        view.ins
        OTMainViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"OTMain"];
        
        [self presentViewController:mainViewController animated:YES completion:nil];
    }
    
    @IBAction func signInActionButton(_ sender: Any) {
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibInit()
    }

    private func xibInit() {
        Bundle.main.loadNibNamed("IdentificationOverlay", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
