//
//  OTPreOnboardingV2ViewController.swift
//  entourage
//
//  Created by Jr on 10/04/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTPreOnboardingV2ViewController: UIViewController {
    
    @IBOutlet weak var ui_customPAgeControl: OTCustomPageControl!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_button_next: UIButton!
    @IBOutlet weak var ui_image_pre_3: UIImageView!
    @IBOutlet weak var ui_collectionView: UICollectionView!
    @IBOutlet weak var ui_bt_connect: UIButton!
    
    @IBOutlet weak var ui_constraint_logo_top: NSLayoutConstraint!
    @IBOutlet weak var ui_constraint_carrousel_top: NSLayoutConstraint!
    @IBOutlet weak var ui_constraint_carrousel_bottom: NSLayoutConstraint!
    @IBOutlet weak var ui_bt_next_constraint_height: NSLayoutConstraint!
    
    var currentPosition = 0
    var itemWidth:CGFloat = 0.0
    
    let cellHeight:CGFloat = 267
    let widthSpacingForCell:CGFloat = 127 // Margin left/right + spacing
    let cornerRadiusImage:CGFloat = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemWidth = view.frame.width - widthSpacingForCell
        
        self.ui_collectionView.collectionViewLayout = OTCarrouselLayout(cellWidth: itemWidth , cellHeight: cellHeight)
        
        self.ui_button_next.layer.cornerRadius = cornerRadiusImage
        
        self.ui_customPAgeControl.currentPage = currentPosition
        updateViewsAtPosition()
        
        self.ui_button_next.setTitle(OTLocalisationService.getLocalizedValue(forKey: "next")?.uppercased(), for: .normal)
        self.ui_bt_connect.setTitle(OTLocalisationService.getLocalizedValue(forKey: "connectMe")?.uppercased(), for: .normal)
        
        //Check iPhone 6/7/8 < / iPhone 5s/SE
        if view.frame.height <= 667 {
            ui_constraint_logo_top.constant = 16
            ui_constraint_carrousel_top.constant = 16
            ui_constraint_carrousel_bottom.constant = 16
            
            if view.frame.height <= 568 {
                ui_label_description.isHidden = true
                ui_bt_next_constraint_height.constant = 40
            }
            self.view.layoutIfNeeded()
        }
        
        OTLogger.logEvent(View_Start_Carrousel1)
    }
    
    func updateViewsAtPosition() {
        self.ui_customPAgeControl.currentPage = currentPosition
        var title = ""
        var titleColored = ""
        var description = ""
        self.ui_image_pre_3.isHidden = true
        switch currentPosition {
        case 0:
            title = OTLocalisationService.getLocalizedValue(forKey: "preOnboard_start_title1")
            titleColored = OTLocalisationService.getLocalizedValue(forKey: "preOnboard_start_title1_colored")
            description = OTLocalisationService.getLocalizedValue(forKey: "preOnboard_start_description1")
        case 1:
            title = OTLocalisationService.getLocalizedValue(forKey: "preOnboard_start_title2")
            titleColored = OTLocalisationService.getLocalizedValue(forKey: "preOnboard_start_title2_colored")
            description = OTLocalisationService.getLocalizedValue(forKey: "preOnboard_start_description2")
            OTLogger.logEvent(View_Start_Carrousel2)
        case 2:
            title = OTLocalisationService.getLocalizedValue(forKey: "preOnboard_start_title3")
            titleColored = OTLocalisationService.getLocalizedValue(forKey: "preOnboard_start_title3_colored")
            description = ""
            ui_image_pre_3.isHidden = view.frame.height <= 568 ? true : false
            OTLogger.logEvent(View_Start_Carrousel3)
        case 3:
            title = OTLocalisationService.getLocalizedValue(forKey: "preOnboard_start_title4")
            titleColored = OTLocalisationService.getLocalizedValue(forKey: "preOnboard_start_title4_colored")
            description = OTLocalisationService.getLocalizedValue(forKey: "preOnboard_start_description4")
            OTLogger.logEvent(View_Start_Carrousel4)
        default:
            break
        }
        
        self.ui_label_title.attributedText = Utilitaires.formatString(stringMessage: title, coloredTxt: titleColored, color: UIColor.black, colorHighlight: UIColor.appOrange(), fontSize: 28,fontWeight: .medium,fontColoredWeight: .medium)
        self.ui_label_description.text = description
    }
    
    @IBAction func action_show_choice(_ sender: Any) {
        self.showChoice()
    }
    
    @IBAction func action_next_end(_ sender: Any) {
        if currentPosition < 3 {
            currentPosition = currentPosition + 1
            let indexPath = IndexPath(item: currentPosition, section: 0)
            
            ui_collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            self.updateViewsAtPosition()
        }
        else {
            self.showChoice()
        }
    }
    
    func showChoice() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PreOnboardingChoice") as! OTPreOnboardingV2ChoiceViewController
        
        self.navigationController?.show(vc, sender: nil)
    }
}

extension OTPreOnboardingV2ViewController: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellImg", for: indexPath) as! OTPre_OnboardCollectionViewCell
        
        switch indexPath.row {
        case 0:
            cell.populateCell(imageName: "pre_onboard_1", width: self.view.frame.width - widthSpacingForCell)
        case 1:
            cell.populateCell(imageName: "pre_onboard_2", width: self.view.frame.width - widthSpacingForCell)
        case 2:
            cell.populateCell(imageName: "pre_onboard_3", width: self.view.frame.width - widthSpacingForCell)
        case 3:
            cell.populateCell(imageName: "pre_onboard_4", width: self.view.frame.width - widthSpacingForCell)
        default:
            break
        }
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: self.ui_collectionView.contentOffset, size: self.ui_collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = self.ui_collectionView.indexPathForItem(at: visiblePoint) {
            self.currentPosition = visibleIndexPath.row
            self.updateViewsAtPosition()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: cellHeight)
    }
}
