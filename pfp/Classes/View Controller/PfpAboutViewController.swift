//
//  PfpTableViewController.swift
//  pfp
//
//  Created by Smart Care on 16/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import UIKit

class PfpAboutViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = OTLocalisationService.getLocalizedValue(forKey: "aboutTitle").uppercased()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "aboutCellId")
        self.tableView.separatorColor = UIColor.clear
        self.tableView.backgroundColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: "aboutCellId")
        
        cell.backgroundColor = UIColor.pfpTableBackground()
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.textLabel?.textColor = ApplicationTheme.shared().titleLabelColor
        cell.textLabel?.font = UIFont.SFUIText(size: 15, type: UIFont.SFUITextFontType.regular)
        cell.detailTextLabel?.textColor = ApplicationTheme.shared().subtitleLabelColor
        cell.detailTextLabel?.font = UIFont.SFUIText(size: 15, type: UIFont.SFUITextFontType.bold)
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = OTLocalisationService.getLocalizedValue(forKey: "about_appVersion")
            //cell.detailTextLabel?.text = "v1.1"
            break
        case 1:
            cell.textLabel?.text = OTLocalisationService.getLocalizedValue(forKey: "about_cgu")
            break
            
        default:
            break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            break
        case 1:
            break
            
        default:
            break
        }
    }
}
