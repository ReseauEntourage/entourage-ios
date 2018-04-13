//
//  OTPopupViewController.swift
//  entourage
//
//  Created by Veronica on 13/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import Foundation

final class OTPopupViewController: UIViewController {
    
    @IBOutlet weak var textWithCount: OTTextWithCount!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var completionButton: UIButton!
    
    let labelString: String?
    let textFieldPlaceholder: String?
    let buttonTitle: String?
    
    init(labelString: String?, textFieldPlaceholder: String?, buttonTitle: String?) {
        self.labelString = labelString
        self.textFieldPlaceholder = textFieldPlaceholder
        self.buttonTitle = buttonTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    //MARK: - private functions
    private func setupUI() {
        descriptionLabel.text = labelString
        completionButton.setTitle(buttonTitle, for: .normal)
        textWithCount.placeholder = textFieldPlaceholder
    }
    
}
