//
//  OTPopupViewController.swift
//  entourage
//
//  Created by Veronica on 13/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import Foundation

@objc final class OTPopupViewController: UIViewController {
    
    @IBOutlet weak var textWithCount: OTTextWithCount!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var completionButton: UIButton!
    @IBOutlet weak var tapBehavior: OTTapViewBehavior!
    @IBOutlet weak var closeKeyboardBehavior: OTCloseKeyboardOnTapBehavior!
    
    lazy var labelString: String = {
        return ""
    }()
    lazy var textFieldPlaceholder = ""
    lazy var buttonTitle = ""
    lazy var message = ""
    lazy var reportedUserId = ""
    
    init(labelString: String, textFieldPlaceholder: String, buttonTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.labelString = labelString
        self.textFieldPlaceholder = textFieldPlaceholder
        self.buttonTitle = buttonTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        closeKeyboardBehavior.inputViews = [textWithCount.textView]
        textWithCount.maxLength = 200
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 100
        IQKeyboardManager.shared().isEnabled = true
        textWithCount.becomeFirstResponder()
        textWithCount.textView?.text = message
        if !message.isEmpty {
            textWithCount.updateAfterSpeech()
        }
    }
    
    //MARK: - private functions
    private func setupUI() {
        descriptionLabel.text = labelString
        completionButton.setTitle(buttonTitle, for: .normal)
        textWithCount.placeholderLargeColor = UIColor.appGreyish()
        textWithCount.placeholder = textFieldPlaceholder
        completionButton.addTarget(self, action: #selector(sendMail), for: .touchUpInside)
    }
    
    @objc private func sendMail() {
        OTUserService.init().reportUser(reportedUserId, message: textWithCount.textView?.text, success: nil, failure: nil)
        close(self)
    }
    
    //MARK: - IBActions
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
