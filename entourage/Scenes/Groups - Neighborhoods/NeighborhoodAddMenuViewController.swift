//
//  NeighborhoodAddMenuViewController.swift
//  entourage
//
//  Created by Jerome on 19/05/2022.
//

import UIKit

class NeighborhoodAddMenuViewController: UIViewController {

    @IBOutlet weak var ui_lb_post: UILabel!
    @IBOutlet weak var ui_lb_event: UILabel!
    
    var neighborhoodId:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_lb_post.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        
        ui_lb_event.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        
        ui_lb_event.text = "neighborhood_menu_post_event".localized
        ui_lb_post.text = "neighborhood_menu_post_post".localized
        
    }
    
    @IBAction func action_close(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func action_create_event(_ sender: Any) {
        showWIP(parentVC: self)
    }
    
    @IBAction func action_create_post(_ sender: Any) {
        let parentVC = presentingViewController
        dismiss(animated: false) {
            let sb = UIStoryboard.init(name: "Neighborhood_Message", bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "addPostVC") as? NeighborhoodPostAddViewController  {
                vc.neighborhoodId = self.neighborhoodId
                parentVC?.present(vc, animated: true)
            }
        }
    }
}
