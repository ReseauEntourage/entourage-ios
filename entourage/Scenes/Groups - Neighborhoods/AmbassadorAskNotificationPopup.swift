//
//  AmbassadorAskNotificationPopup.swift
//  entourage
//
//  Created by Clement entourage on 26/09/2024.
//

import Foundation
import UIKit

protocol AmbassadorAskNotificationPopupDelegate: AnyObject {
    func joinAsOrganizer()
    func justParticipate()
}

class AmbassadorAskNotificationPopup: UIViewController {
    
    // OUTLET
    @IBOutlet weak var ui_btn_return: UIButton! // Organisateur
    @IBOutlet weak var ui_button_start: UIButton! // Participant
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_label: UILabel! // Titre orange
    @IBOutlet weak var ui_label_description: UILabel! // Titre gris
    
    // VARIABLE
    weak var delegate: AmbassadorAskNotificationPopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        // Add button actions
        ui_btn_return.addTarget(self, action: #selector(onJoinAsOrganizer), for: .touchUpInside)
        ui_button_start.addTarget(self, action: #selector(onJustParticipate), for: .touchUpInside)
    }
    
    private func configureUI() {
        // Configure labels
        ui_label.text = NSLocalizedString("ambassador_ask_notification_title", comment: "")
        ui_label_description.text = NSLocalizedString("ambassador_ask_notification_description", comment: "")
        
        // Configure buttons
        configureWhiteButton(ui_btn_return, withTitle: NSLocalizedString("ambassador_ask_notification_button_organizer", comment: ""))
        configureOrangeButton(ui_button_start, withTitle: NSLocalizedString("ambassador_ask_notification_button_participant", comment: ""))
    }
    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }

    func configureWhiteButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.appOrange.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }
    
    // MARK: - Button Actions
    @objc private func onJoinAsOrganizer() {
        delegate?.joinAsOrganizer()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onJustParticipate() {
        delegate?.justParticipate()
        dismiss(animated: true, completion: nil)
    }
}
