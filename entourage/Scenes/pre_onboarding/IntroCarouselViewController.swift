//
//  IntroCarouselViewController.swift
//  entourage
//
//  Created by You on 29/11/2022.
//  Copyright © 2022 Entourage. All rights reserved.
//

import UIKit

class IntroCarouselViewController: UIViewController {
    
    @IBOutlet weak var ui_logo_entourage: UIImageView!
    @IBOutlet weak var ui_customPageControl: MJCustomPageControl!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_button_next: UIButton!
    @IBOutlet weak var ui_collectionView: UICollectionView!
    @IBOutlet weak var ui_bt_connect: UIButton!
    
    @IBOutlet weak var ui_button_previous: UIButton!
    @IBOutlet weak var ui_constraint_carrousel_top: NSLayoutConstraint!
    @IBOutlet weak var ui_bt_next_constraint_height: NSLayoutConstraint!
    
    var currentPosition = 0
    var itemWidth:CGFloat = 0.0
    
    let cellHeight:CGFloat = 348
    let cornerRadiusImage:CGFloat = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemWidth = view.frame.width
        
        ui_label_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange(size: 24))
        ui_label_description.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 17))
        ui_bt_connect.setupFontAndColor(style: ApplicationTheme.getFontBoutonOrange())
        ui_button_next.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        ui_button_previous.setupFontAndColor(style: ApplicationTheme.getFontBoutonOrange())
        
        self.ui_collectionView.collectionViewLayout = OTCarrouselLayout(cellWidth: itemWidth , cellHeight: cellHeight)
        
        self.ui_button_next.layer.cornerRadius = cornerRadiusImage
        ui_customPageControl.numberOfPages = 3
        self.ui_customPageControl.currentPage = currentPosition
        updateViewsAtPosition()
        
        self.ui_button_next.setTitle( "next".localized, for: .normal)
        self.ui_button_previous.setTitle( "previous".localized, for: .normal)
        
        ui_button_next.layer.cornerRadius = ui_button_next.frame.height / 2
        ui_button_previous.layer.cornerRadius = ui_button_previous.frame.height / 2
        
        self.ui_bt_connect.setTitle( "bt_pass".localized, for: .normal)
        
        //Check iPhone 6/7/8 < / iPhone 5s/SE
        if view.frame.height <= 667 {
            ui_constraint_carrousel_top.constant = 0
            
            if view.frame.height <= 568 {
                ui_label_description.isHidden = true
                ui_bt_next_constraint_height.constant = 0
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func updateViewsAtPosition() {
        self.ui_customPageControl.currentPage = currentPosition
        var title = ""
        var description = ""
        ui_logo_entourage.isHidden = true
        ui_button_previous.isHidden = false
        ui_bt_connect.isHidden = false
        switch currentPosition {
        case 0:
            title =  "intro_title_1".localized
            description =  "intro_subtitle_1".localized
            ui_logo_entourage.isHidden = false
            ui_button_previous.isHidden = true
            AnalyticsLoggerManager.logEvent(name: PreOnboard_car1)
        case 1:
            title =  "intro_title_2".localized
            description =  "intro_subtitle_2".localized
            AnalyticsLoggerManager.logEvent(name: PreOnboard_car2)
        case 2:
            title =  "intro_title_3".localized
            description = "intro_subtitle_3".localized
            ui_bt_connect.isHidden = true
            AnalyticsLoggerManager.logEvent(name: PreOnboard_car3)
        default:
            break
        }
        
        self.ui_label_title.text = title
        self.ui_label_description.text = description
    }
    
    @IBAction func action_show_choice(_ sender: Any) {
        self.showChoice()
    }
    
    @IBAction func action_previous(_ sender: Any) {
        currentPosition = currentPosition - 1
        let indexPath = IndexPath(item: currentPosition, section: 0)
        
        ui_collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        self.updateViewsAtPosition()
    }
    
    @IBAction func action_next_end(_ sender: Any) {
        if currentPosition < 2 {
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

extension IntroCarouselViewController: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellImg", for: indexPath) as! OTPre_OnboardCollectionViewCell
        
        switch indexPath.row {
        case 0:
            cell.populateCell(imageName: "carousel_onboarding 1", width: self.view.frame.width)
        case 1:
            cell.populateCell(imageName: "carousel_onboarding 2", width: self.view.frame.width)
        case 2:
            cell.populateCell(imageName: "carousel_onboarding 3", width: self.view.frame.width)
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
