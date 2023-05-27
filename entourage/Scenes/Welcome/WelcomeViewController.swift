//
//  WelcomeViewController.swift
//  entourage
//
//  Created by Clement entourage on 17/05/2023.
//

import Foundation


class WelcomeViewController:UIViewController {
    //OUTLET VAR
    @IBOutlet weak var ui_imagebtn_back: UIImageView!
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    // MACHINE VAR
    
    
    override func viewDidLoad() {
        
    }
    
}

extension WelcomeViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
