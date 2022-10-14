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

//        NeighborhoodService.getAllNeighborhoods { groups, error in
//            Logger.print("***** return get groups:  \(groups)")
//        }
//
//        NeighborhoodService.getNeighborhoodDetail(id: 1) { group, error in
//            Logger.print("***** group ? \(group) - error: \(error)")
//        }
    }
    

    @IBAction func show(_ sender: Any) {
        Logger.print("***** show")
        
        let  navVC = UIStoryboard.init(name: "Neighborhood", bundle: nil).instantiateViewController(withIdentifier: "groupCreateVCMain")
        navVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(navVC, animated: true)
        
//        var group = Neighborhood()
//        group.name = "Le Groupe2"
////        group.aboutGroup = "La description du groupe"
////        group.aboutEthics = "Charte éthique ?"
////        group.welcomeMessage = "Le message de bienvenue"
////        group.latitude = 2.0
////        group.longitude = 43.0
////        group.interests = ["sport"]
////        group.photoUrl = "Url photo ;)"
//
//        group.uid = 2
//
//        NeighborhoodService.updateNeighborhood(group: group) { group,error in
//            Logger.print("***** return update group : \(group) error:? \(error)")
//        }
        
    }

}
