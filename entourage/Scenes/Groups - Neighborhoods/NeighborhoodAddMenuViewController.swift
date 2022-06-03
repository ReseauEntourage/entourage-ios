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
        AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_Plus)
    }
    
    @IBAction func action_close(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_Plus_Close)
        self.dismiss(animated: true)
    }
    
    @IBAction func action_create_event(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_NewEvent)
        showWIP(parentVC: self)
    }
    
    @IBAction func action_create_post(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_NewPost)
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
