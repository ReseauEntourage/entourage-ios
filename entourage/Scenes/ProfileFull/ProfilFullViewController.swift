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
    @IBOutlet weak var ui_table_view: UITableView!
    @IBOutlet weak var img_profile: UIImageView!
    @IBOutlet weak var btn_back: UIImageView!
    @IBOutlet weak var btn_signal: UIImageView!
    
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
