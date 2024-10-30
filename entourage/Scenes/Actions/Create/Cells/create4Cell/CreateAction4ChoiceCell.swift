//
//  CreateAction4ChoiceCell.swift
//  entourage
//
//  Created by Clement entourage on 28/10/2024.
//

import Foundation
import UIKit

protocol CreateAction4ChoiceCellDelegate: AnyObject {
    func didUpdateShareToGroup(_ shareToGroup: Bool?)
}

class CreateAction4ChoiceCell: UITableViewCell {
    class var identifier: String {
        return String(describing: self)
    }
    
    // OUTLETS
    @IBOutlet weak var img_choice_yes: UIImageView!
    @IBOutlet weak var img_choice_no: UIImageView!
    @IBOutlet weak var ui_label_choice_yes: UILabel!
    @IBOutlet weak var ui_label_choice_no: UILabel!
    
    // Variables
    weak var delegate: CreateAction4ChoiceCellDelegate?
    private var shareToGroup: Bool? = nil {
        didSet {
            delegate?.didUpdateShareToGroup(shareToGroup)
            updateUIForChoice()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
        setupGestures()
        updateUIForChoice() // Initialise l'interface utilisateur sans sélection
    }
    
    // Configure the cell with localized text and default styles
    func configure() {
        ui_label_choice_yes.text = "yes".localized
        ui_label_choice_no.text = "no".localized
        ui_label_choice_yes.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13))
        ui_label_choice_no.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13))
    }
    
    // Set up gesture recognizers for each label and image separately
    private func setupGestures() {
        let tapYesImage = UITapGestureRecognizer(target: self, action: #selector(didSelectYes))
        let tapNoImage = UITapGestureRecognizer(target: self, action: #selector(didSelectNo))
        let tapYesLabel = UITapGestureRecognizer(target: self, action: #selector(didSelectYes))
        let tapNoLabel = UITapGestureRecognizer(target: self, action: #selector(didSelectNo))
        
        img_choice_yes.addGestureRecognizer(tapYesImage)
        img_choice_no.addGestureRecognizer(tapNoImage)
        ui_label_choice_yes.addGestureRecognizer(tapYesLabel)
        ui_label_choice_no.addGestureRecognizer(tapNoLabel)
        
        img_choice_yes.isUserInteractionEnabled = true
        img_choice_no.isUserInteractionEnabled = true
        ui_label_choice_yes.isUserInteractionEnabled = true
        ui_label_choice_no.isUserInteractionEnabled = true
    }
    
    // Update UI based on the choice
    private func updateUIForChoice() {
        switch shareToGroup {
        case true:
            ui_label_choice_yes.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 15))
            ui_label_choice_no.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13))
            img_choice_yes.image = UIImage(named: "ic_group_action_chosen")
            img_choice_no.image = UIImage(named: "ic_group_action_unchosen")
            
        case false:
            ui_label_choice_yes.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13))
            ui_label_choice_no.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 15))
            img_choice_yes.image = UIImage(named: "ic_group_action_unchosen")
            img_choice_no.image = UIImage(named: "ic_group_action_chosen")
            
        case nil:
            // Si rien n'est choisi, mettre les labels et images en état "neutre"
            ui_label_choice_yes.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13))
            ui_label_choice_no.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13))
            img_choice_yes.image = UIImage(named: "ic_group_action_unchosen")
            img_choice_no.image = UIImage(named: "ic_group_action_unchosen")
        case .some(_):
            ui_label_choice_yes.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13))
            ui_label_choice_no.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13))
            img_choice_yes.image = UIImage(named: "ic_group_action_unchosen")
            img_choice_no.image = UIImage(named: "ic_group_action_unchosen")
        }
    }
    
    // MARK: - Actions
    
    @objc private func didSelectYes() {
        shareToGroup = true
    }
    
    @objc private func didSelectNo() {
        shareToGroup = false
    }
}
