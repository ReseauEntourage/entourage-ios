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
    var selectedCircle:OTUserMembershipListItem?

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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.userCircles = UserDefaults.standard.currentUser.privateCircles()
        
        if let firstCircle = self.userCircles.first {
            self.selectCircle(firstCircle, isSelected:true)
        } else {
            self.tableView.reloadData()
        }
    }
    
    private func selectCircle (_ circle: OTUserMembershipListItem, isSelected:Bool) {
        for item in self.userCircles {
            item.isSelected = false
            if item === circle {
                item.isSelected = isSelected
                if isSelected {
                    self.selectedCircle = circle
                } else {
                    self.selectedCircle = nil
                }
            }
        }
        
        self.tableView.reloadData()
        self.updateNavigationItems()
    }
    
    @objc private func continueAction () {
        let storyboard:UIStoryboard = UIStoryboard.init(name: "PfpUserVoisinage", bundle: nil)
        let vc:PfpSelectVisitDateViewController = storyboard.instantiateViewController(withIdentifier: "PfpSelectVisitDateViewController") as! PfpSelectVisitDateViewController
        vc.privateCircle = self.selectedCircle
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateNavigationItems () {
        let continueButton:UIBarButtonItem = UIBarButtonItem.init(title: String.localized("continue"),
                                                                  style: UIBarButtonItemStyle.plain,
                                                                  target: self,
                                                                  action: #selector(continueAction))
        
        if let _:OTUserMembershipListItem = (self.userCircles.filter {$0.isSelected == true}).first {
            self.navigationItem.rightBarButtonItem = continueButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
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
    }
}
