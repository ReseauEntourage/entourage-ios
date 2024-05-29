//
//  EnhancedViewController.swift
//  entourage
//
//  Created by Clement entourage on 23/05/2024.
//

import Foundation
import UIKit

 enum EnhancedOnboardingTableDTO {
     case title(title:String, subtitle:String)
     case fullSizeCell(title:String, image:String, isSelected:Bool)
    case collectionViewCell
    case buttonCell
}

enum EnhancedOnboardingMode {
    case interest // centre d'intérêt
    case concern // Entraides
    case involvement // envie d'agir
}

class EnhancedViewController: UIViewController {
    
    // OUTLET
    @IBOutlet weak var ui_tableview: UITableView!
    
    // Variables
    var tableDTO = [EnhancedOnboardingTableDTO]()
    var mode:EnhancedOnboardingMode = .involvement
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell class
        //ui_tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Assign delegates
        ui_tableview.delegate = self
        ui_tableview.dataSource = self
    }
    
    private func loadDTO(){
        //Add cell to dto
        switch self.mode {
            
        case .interest:
            tableDTO.append(.title(title: "", subtitle: ""))
        case .concern:
            tableDTO.append(.title(title: "", subtitle: ""))
        case .involvement:
            tableDTO.append(.title(title: "", subtitle: ""))

        }
    }
    
    func presentViewControllerWithAnimation(identifier: String) {
            let storyboard = UIStoryboard(name: "EnhancedOnboarding", bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? UIViewController {
                viewController.modalPresentationStyle = .fullScreen
                viewController.modalTransitionStyle = .coverVertical
                present(viewController, animated: true, completion: nil)
            }
        }
}

extension EnhancedViewController: UITableViewDelegate, UITableViewDataSource {

    
    // Number of rows in the section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    // Configure the cell for the row at indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    
    // Handle row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


extension EnhancedViewController:EnhancedOnboardingButtonDelegate{
    func onConfigureLaterClick() {
        
    }
    
    func onNextClick() {
        
    }
    
}
