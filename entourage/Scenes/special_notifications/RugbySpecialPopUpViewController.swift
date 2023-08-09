//
//  RugbySpecialPopUpViewController.swift
//  entourage
//
//  Created by Clement entourage on 03/08/2023.
//

import Foundation

class RugbySpecialPopUpViewController:UIViewController{
    
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_content: UILabel!
    @IBOutlet weak var ui_image_cross: UIImageView!
    @IBOutlet weak var btn_cancel: UIButton!
    @IBOutlet weak var btn_join: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        ui_label_title.text = "pop_up_rugby_france_title".localized
        ui_label_content.text = "pop_up_rugby_france_content".localized
        ui_image_cross.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onCrossClicked(tapGestureRecognizer:)))
        ui_image_cross.addGestureRecognizer(tapGestureRecognizer)
        
        btn_cancel.addTarget(self, action: #selector(onBtnCancelClicked), for: .touchUpInside)
        btn_join.addTarget(self, action: #selector(onBtnJoinClicked), for: .touchUpInside)
    }
    
    @objc func onCrossClicked(tapGestureRecognizer: UITapGestureRecognizer){
        self.dismiss(animated: true) {
            
        }
    }
    
    @objc func onBtnCancelClicked(){
        self.dismiss(animated: true) {
            
        }
    }
    @objc func onBtnJoinClicked(){
        self.dismiss(animated: true) {
            let sb = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil)
            if let nav = sb.instantiateViewController(withIdentifier: "neighborhoodDetailNav") as? UINavigationController, let vc = nav.topViewController as? NeighborhoodDetailViewController {
                vc.neighborhoodId = 44
                AppState.getTopViewController()?.navigationController?.present(nav, animated: true)
            }
        }
    }
    
}
