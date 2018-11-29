//
//  OTIdentificationOverlayView.swift
//  entourage
//
//  Created by Moulinet Chloë on 19/10/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import UIKit

class OTIdentificationOverlayView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var popUpContainer: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBAction func signUpActionButton(_ sender: Any) {
        OTAppState.continueFromWelcomeScreenForOnboarding()
    }
    
    @IBAction func signInActionButton(_ sender: Any) {
        OTAppState.continueFromStartupScreenForOnboarding()
    }
    
    @IBAction func closeActionButton(_ sender: Any) {
        self.alpha = 0
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
        self.backgroundColor = UIColor.clear
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        setup()
    }
    
    func setup() {
        popUpContainer.layer.cornerRadius = 8
        signUpButton.layer.cornerRadius = 25
    }
}
