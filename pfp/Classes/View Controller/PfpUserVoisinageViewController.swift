//
//  PfpUserCirclesViewController.swift
//  pfp
//
//  Created by Smart Care on 04/06/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import UIKit

class PfpUserVoisinageViewController: UITableViewController {
    
    var userCircles:[OTUserMembershipListItem] = [OTUserMembershipListItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = String.localized("pfp_user_voisinage_title").uppercased()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userCircles = UserDefaults.standard.currentUser.privateCircles()
        self.tableView.reloadData()
    }
    
    private func selectCircle (_ circle: OTUserMembershipListItem, isSelected:Bool) {
        for item in self.userCircles {
            item.isSelected = false
            if item === circle {
                item.isSelected = isSelected
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userCircles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PfpUserCircleCell = tableView.dequeueReusableCell(withIdentifier: "UserCircleCell", for: indexPath) as! PfpUserCircleCell
        cell.updateWithUserCircle(self.userCircles[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let circle:OTUserMembershipListItem = self.userCircles[indexPath.row]
        self.selectCircle(circle, isSelected: !circle.isSelected)
        tableView.reloadData()
    }
}
