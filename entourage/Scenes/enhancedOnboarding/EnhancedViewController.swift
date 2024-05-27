//
//  EnhancedViewController.swift
//  entourage
//
//  Created by Clement entourage on 23/05/2024.
//

import Foundation
import UIKit

 enum EnhancedOnboardingTableDTO {
    case title
    case fullSizeCell
    case collectionViewCell
    case buttonCell
}

class EnhancedViewController: UIViewController {
    
    // OUTLET
    @IBOutlet weak var ui_tableview: UITableView!
    
    // Variables
    var tableDTO = [EnhancedOnboardingTableDTO]()
    
    
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
