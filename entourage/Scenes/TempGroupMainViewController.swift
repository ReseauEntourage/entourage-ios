//
//  TempGroupMainViewController.swift
//  entourage
//
//  Created by Jerome on 01/04/2022.
//

import UIKit

class TempGroupMainViewController: UIViewController {

   
    override func viewDidLoad() {
        super.viewDidLoad()
        MetadatasService.getMetadatas { error in
            Logger.print("***** return get metadats ? \(error)")
        }
        
       
        
    }
    
    @IBAction func action_show_my_profile(_ sender: Any) {
         let navVC = UIStoryboard.init(name: "ProfileParams", bundle: nil).instantiateViewController(withIdentifier: "mainNavProfile")  //mainNavProfile
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
        
        
    }
    
    @IBAction func show(_ sender: Any) {
        Logger.print("***** show")
        
        let  navVC = UIStoryboard.init(name: "Neighborhood_Create", bundle: nil).instantiateViewController(withIdentifier: "groupCreateVCMain") as! NeighborhoodCreateMainViewController
        navVC.parentController = self.tabBarController
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
        
        
    }

    @IBAction func action_edit_group(_ sender: Any) {
        let  navVC = UIStoryboard.init(name: "Neighborhood_Create", bundle: nil).instantiateViewController(withIdentifier: "editGroupVC")
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
        
    }
    
    @IBAction func action_show_users(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "tempUsersVC") {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
