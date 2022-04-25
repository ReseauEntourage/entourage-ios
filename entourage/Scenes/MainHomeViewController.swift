//
//  MainHomeViewController.swift
//  entourage
//
//  Created by Jerome on 14/03/2022.
//

import UIKit

class MainHomeViewController: UIViewController {

    @IBOutlet weak var ui_top_bar: MJNavBackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        MetadatasService.getMetadatas { error in
            Logger.print("***** return get metadats ? \(error)")
        }
        
        ui_top_bar.populateView(title: "HOME".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: false)
    }
    
    @IBAction func show_user(_ sender: UIButton) {
        
        switch sender.tag {
        case -1:
            showUser(id: "3193") //User 10
        case 0:
            showUser(id: "3802") //Complet
        case 1:
            showUser(id: "3673") //aa vide 2874
        case 2:
            showUser(id: "3556") //pesquet
        default:
            break
        }
    }
    
    func showUser(id:String) {
        //userProfileNavVC
        //userProfileVC
        if let  navVC = UIStoryboard.init(name: "UserDetail", bundle: nil).instantiateViewController(withIdentifier: "userProfileNavVC") as? UINavigationController {
            if let _homeVC = navVC.topViewController as? UserProfileDetailViewController {
                _homeVC.currentUserId = id
                
                self.tabBarController?.present(navVC, animated: true)
            }
        }
        
    }
}

//MARK: - MJNavBackViewDelegate -
extension MainHomeViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
