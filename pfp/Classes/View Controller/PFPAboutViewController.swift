//
//  PFPAboutViewController.swift
//  entourage
//
//  Created by Smart Care on 17/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import UIKit
import StoreKit

class PFPAboutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SKStoreProductViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
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
    
    private func openStoreProductWithiTunesItemIdentifier(identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
        storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) -> Void in
            if loaded {
                // Parent class of self is UIViewContorller
                self?.present(storeViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: "aboutCellId")
        let textSize: CGFloat = 15
        cell.backgroundColor = UIColor.pfpTableBackground()
        cell.accessoryType = UITableViewCellAccessoryType.none
        cell.textLabel?.textColor = ApplicationTheme.shared().titleLabelColor
        cell.textLabel?.font = UIFont.SFUIText(size: textSize, type: UIFont.SFUITextFontType.regular)
        cell.detailTextLabel?.textColor = ApplicationTheme.shared().subtitleLabelColor
        cell.detailTextLabel?.font = UIFont.SFUIText(size: textSize, type: UIFont.SFUITextFontType.bold)
        
        let arrowImage:UIImage = UIImage.init(named: "arrowForMenu")!
        let imageView:UIImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: textSize, height: textSize))
        imageView.image = arrowImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imageView.tintColor = ApplicationTheme.shared().subtitleLabelColor
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        cell.accessoryView = imageView
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = OTLocalisationService.getLocalizedValue(forKey: "about_appVersion")
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                cell.detailTextLabel?.text = "v\(version)"
            }
            break
        case 1:
            cell.textLabel?.text = OTLocalisationService.getLocalizedValue(forKey: "about_cgu")
            break
        case 2:
            cell.textLabel?.text = OTLocalisationService.getLocalizedValue(forKey: "about_privacy_policy")
            break
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            self.openStoreProductWithiTunesItemIdentifier(identifier: ITUNES_APP_ID);
            break
        case 1:
            let url = URL(string: "http://bit.ly/cgu_applivoisin-age")
            OTSafariService.launchInAppBrowser(with: url, viewController: self.navigationController)
            break
        case 2:
            OTSafariService.launchPrivacyPolicyForm(in: self.navigationController)
            break
            
        default:
            break
        }
    }
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }

}
