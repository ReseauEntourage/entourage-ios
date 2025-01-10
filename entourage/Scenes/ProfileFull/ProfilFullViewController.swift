//
//  ProfilFullViewController.swift
//  entourage
//
//  Created by Clement entourage on 09/01/2025.
//

import Foundation
import UIKit

class ProfilFullViewController:UIViewController{
    
    //OUTLET
    
    //VARIABLE
    
    override func viewDidLoad() {
        
    }
    
}

extension ProfilFullViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
